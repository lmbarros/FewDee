/**
 * The game engine. The engine is implemented as a module, with a bunch of free
 * functions. This is similar to a singleton, just without lying to myself and
 * pretending that I am not using globals. All functions are thread safe (if
 * they are not, that's a bug).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.engine;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_ttf;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import fewdee.event;
import fewdee.game_state;
import fewdee.ref_counted_wrappers;
import fewdee.state_manager;


/// The one and only display (window) where we show things.
private AllegroDisplay TheDisplay;

/// The source of custom events.
private ALLEGRO_EVENT_SOURCE TheCustomEventSource;

/// The one and only event queue.
private ALLEGRO_EVENT_QUEUE* TheEventQueue;

/// The object managing the game states.
private StateManager TheStateManager;



// xxxxxxx doc-me. And maybe move to a different module.
struct DisplayParams
{
   bool fullScreen = true;
   bool useDesktopResolution = true;
   uint width = 640;
   uint height = 480;
   bool vSync = true;
   int monitor = 0;
}


/**
 * A handy way to start the engine (and stop it). Crank, handy, start an
 * engine... witty naming, uh?
 *
 * This is a value type (struct), so that we guarantee that its destructor will
 * Notice that this is a "scope class", so it must be instantiated with the $(D
 * scope) keyword.
 *
 * See_also: https://en.wikipedia.org/wiki/Crank_%28mechanism%29#20th_Century
 */
scope class Crank
{
   /**
    * Creates the $D(Crank), which causes the engine to be started ($(D
    * fewdee.engine.start()) is called).
    *
    * Params:
    *    createDisplay = If $(D true) (the default), a Display will be created
    *       when initializing the engine.
    *    dp = The parameters describing the display that will be created as part
    *       of the engine initialization process. This is ignored if $(D
    *       createDisplay == false).
    */
   this(bool createDisplay = true, in DisplayParams dp = DisplayParams())
   {
      fewdee.engine.start();
      if (createDisplay)
         fewdee.engine.createDisplay(dp);
   }

   /**
    * Destroys the $D(Crank), which causes the engine to be stopped
    * ($D(fewdee.engine.stop()) is called).
    */
   ~this()
   {
      fewdee.engine.stop();
   }
}




/**
 * Starts the engine. This sets everything up so that the engine can be used,
 * and must be called before any other $(D fewdee.engine) function.
 *
 * That said, you should use a tool to start the engine: $(D Crank) (crude, but
 * effective).
 *
 * See_also: Crank
 */
void start()
{
   // A "macro" for initializing something with the proper error checking,
   // recovery and reporting.
   string makeInitCode(string initCode, string cleanupCode, string errMsg)
   {
      return "if (!" ~ initCode ~ ")
                    throw new Exception(\"" ~ errMsg ~ "\");
                 scope (failure) " ~ cleanupCode ~ ";";
   }

   mixin (makeInitCode("al_init()", "al_uninstall_system()",
                       "Initialization failed miserably"));

   mixin (makeInitCode("al_init_image_addon()", "al_shutdown_image_addon()",
                       "Error initializing image subsystem"));

   mixin (makeInitCode("(al_init_font_addon(), true)",
                       "al_shutdown_font_addon()",
                       "Error initializing font subsystem"));

   mixin (makeInitCode("al_init_ttf_addon()", "al_shutdown_ttf_addon()",
                       "Error initializing font subsystem"));

   mixin (makeInitCode("al_init_primitives_addon()",
                       "al_shutdown_primitives_addon()",
                       "Error initializing font subsystem"));

   mixin (makeInitCode("al_install_mouse()", "al_uninstall_mouse()",
                       "Error initializing mouse"));

   mixin (makeInitCode("al_install_keyboard()", "al_uninstall_keyboard()",
                       "Error initializing keyboard"));

   mixin (makeInitCode("al_install_joystick()", "al_uninstall_joystick()",
                       "Error initializing joystick"));

   al_init_user_event_source(&TheCustomEventSource);
   scope (failure)
      al_destroy_user_event_source(&TheCustomEventSource);

   TheEventQueue = al_create_event_queue();
   mixin (makeInitCode("(TheEventQueue !is null)",
                       "al_destroy_event_queue(TheEventQueue)",
                       "Error creating event queue."));

   al_register_event_source(TheEventQueue, al_get_mouse_event_source());
   al_register_event_source(TheEventQueue, al_get_keyboard_event_source());
   al_register_event_source(TheEventQueue, al_get_joystick_event_source());
   al_register_event_source(TheEventQueue, &TheCustomEventSource);

   // Don't use pre-multiplied alpha by default
   al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD,
                  ALLEGRO_BLEND_MODE.ALLEGRO_ALPHA,
                  ALLEGRO_BLEND_MODE.ALLEGRO_INVERSE_ALPHA);

   al_set_new_bitmap_flags(ALLEGRO_NO_PREMULTIPLIED_ALPHA
                           | ALLEGRO_MIN_LINEAR
                           | ALLEGRO_MAG_LINEAR);
}


/**
 * Stops the engine. This sets shuts everything down so that your program shuts
 * down gracefully. You cannot call any other $(D fewdee.engine) after calling
 * this function.
 *
 * BTW, you should use a $(D Crank) to start and stop the engine, instead of
 * calling this manually.
 *
 * See_also: Crank
 */
void stop()
{
   al_destroy_event_queue(TheEventQueue);

   al_destroy_user_event_source(&TheCustomEventSource);

   al_uninstall_joystick();

   al_uninstall_keyboard();

   al_uninstall_mouse();

   if (TheDisplay !is null)
      al_destroy_display(TheDisplay);

   al_shutdown_primitives_addon();

   al_shutdown_ttf_addon();

   al_shutdown_font_addon();

   al_shutdown_image_addon();

   al_uninstall_system();
}


// xxxxxxx doc-me
void createDisplay(const ref DisplayParams dp)
{
   TheDisplay = AllegroDisplay(dp.width, dp.height);
   if (TheDisplay is null)
      throw new Exception("Error creating display.");

   scope (failure)
      al_destroy_display(TheDisplay);

   al_register_event_source(TheEventQueue,
                            al_get_display_event_source(TheDisplay));
}



/// Runs the engine main loop, with a given starting state.
void run(GameState startingState)
{
   TheStateManager.pushState(startingState);

   double prevTime = al_get_time();

   while (!TheStateManager.empty)
   {
      // What time is it?
      double now = al_get_time();
      auto deltaTime = now - prevTime;
      prevTime = now;

      // Generate tick event
      ALLEGRO_EVENT tickEvent;
      tickEvent.user.type = FEWDEE_EVENT_TICK;
      tickEvent.user.deltaTime(deltaTime);
      al_emit_user_event(&TheCustomEventSource, &tickEvent, null);

      // Handle pending events
      ALLEGRO_EVENT event;
      while (al_get_next_event(TheEventQueue, &event))
         TheStateManager.onEvent(event);

      // Draw!
      al_set_target_backbuffer(TheDisplay);
      TheStateManager.onDraw();
      al_flip_display();
   }
}
