/**
 * The game engine.
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
import fewdee.state_manager;

/**
 * The Game Engine.
 *
 * This is a value type (struct), so that we guarantee that its destructor will
 * be called when going out of scope. Notice, though, that an Engine is
 * non-copyable.
 */
struct Engine
{
   // Disable copy.
   @disable this(this) { }

   /// Constructs the Engine
   this(uint screenWidth, uint screenHeight)
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

      display_ = al_create_display(screenWidth, screenHeight);
      mixin (makeInitCode("(display_ !is null)", "al_destroy_display(display_)",
                          "Error creating display."));

      mixin (makeInitCode("al_install_mouse()", "al_uninstall_mouse()",
                          "Error initializing mouse"));

      mixin (makeInitCode("al_install_keyboard()", "al_uninstall_keyboard()",
                          "Error initializing keyboard"));

      al_init_user_event_source(&customEventSource_);
      scope (failure)
         al_destroy_user_event_source(&customEventSource_);

      eventQueue_ = al_create_event_queue();
      mixin (makeInitCode("(eventQueue_ !is null)",
                          "al_destroy_event_queue(eventQueue_)",
                          "Error creating event queue."));

      al_register_event_source(eventQueue_,
                               al_get_display_event_source(display_));
      al_register_event_source(eventQueue_, al_get_mouse_event_source());
      al_register_event_source(eventQueue_, al_get_keyboard_event_source());
      al_register_event_source(eventQueue_, &customEventSource_);
   }

   /// Destroys the Engine
   ~this()
   {
      al_destroy_event_queue(eventQueue_);

      al_destroy_user_event_source(&customEventSource_);

      al_uninstall_keyboard();

      al_uninstall_mouse();

      if (display_ !is null)
         al_destroy_display(display_);

      al_shutdown_primitives_addon();

      al_shutdown_ttf_addon();

      al_shutdown_font_addon();

      al_shutdown_image_addon();

      al_uninstall_system();
   }


   /// Runs the engine main loop, with a given starting state.
   void run(GameState startingState)
   {
      stateManager_.pushState(startingState);

      double prevTime = al_get_time();

      while (!stateManager_.empty)
      {
         // What time is it?
         double now = al_get_time();
         auto deltaTime = now - prevTime;
         prevTime = now;

         // Generate tick event
         ALLEGRO_EVENT tickEvent;
         tickEvent.user.type = FEWDEE_EVENT_TICK;
         tickEvent.user.deltaTime(deltaTime);
         al_emit_user_event(&customEventSource_, &tickEvent, null);

         // Handle pending events
         ALLEGRO_EVENT event;
         while (al_get_next_event(eventQueue_, &event))
            stateManager_.onEvent(event);

         // Draw!
         al_set_target_backbuffer(display_);
         stateManager_.onDraw();
         al_flip_display();
      }
   }

   /// The one and only display (window) where we show things.
   private ALLEGRO_DISPLAY* display_;

   /// The source of custom events.
   private ALLEGRO_EVENT_SOURCE customEventSource_;

   /// The one and only event queue.
   private ALLEGRO_EVENT_QUEUE* eventQueue_;

   /// The object managing the game states.
   private StateManager stateManager_;
}
