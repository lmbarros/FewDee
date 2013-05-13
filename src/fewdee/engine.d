/**
 * The game engine. The engine is implemented as a module, with a bunch of free
 * functions. This is similar to a singleton, just without lying to myself and
 * pretending that I am not using globals. All functions are thread safe (if
 * they are not, that's a bug).
 *
 * TODO: rename this to "core"?
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.engine;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_ttf;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import fewdee.aux.singleton;
import fewdee.event;
import fewdee.game_state;
import fewdee.ref_counted_wrappers;
import fewdee.state_manager;
import fewdee.display_manager;


shared static this()
{
   Core.start();
}

shared static ~this()
{
   Core.stop();
}


// TODO: review docs! Er, and everything else!
private class CoreImpl
{
   /**
    * Starts the core. This sets everything up so that the engine can be used,
    * and must be called before any other $(D fewdee.engine) function.
    *
    * That said, you should use a tool to start the engine: $(D Crank) (crude,
    * but effective).
    */
   private void start()
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
    * Stops the engine. This sets shuts everything down so that your program
    * shuts down gracefully. You cannot call any other $(D fewdee.engine) after
    * calling this function.
    *
    * BTW, you should use a $(D Crank) to start and stop the engine, instead of
    * calling this manually.
    *
    * See_also: Crank
    */
   private void stop()
   {
      al_destroy_event_queue(TheEventQueue);

      al_destroy_user_event_source(&TheCustomEventSource);

      al_uninstall_joystick();

      al_uninstall_keyboard();

      al_uninstall_mouse();

      DisplayManager.finalize(); // TODO: must check if initialized

      al_shutdown_primitives_addon();

      al_shutdown_ttf_addon();

      al_shutdown_font_addon();

      al_shutdown_image_addon();

      al_uninstall_system();
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

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public ALLEGRO_DISPLAY* TheDisplay;

   /// The source of custom events.
   private ALLEGRO_EVENT_SOURCE TheCustomEventSource;

   /// The one and only event queue.
   package ALLEGRO_EVENT_QUEUE* TheEventQueue;

   /// The object managing the game states.
   private StateManager TheStateManager;

   /**
    * Is the Display Manager initialized? Only the Display Manager itself should
    * set this to $(D true).
    */
   package bool isDisplayManagerInited = false;

   /**
    * Is the Event Manager initialized? Only the Event Manager itself should set
    * this to $(D true).
    */
   package bool isEventManagerInited = false;
}


/**
 * The Core singleton. Provides access to the one and only $(D
 * CoreImpl) instance.
 */
public class Core
{
   mixin LowLockSingleton!CoreImpl;
}
