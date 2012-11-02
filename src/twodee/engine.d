/**
 * The game engine.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.engine;

import allegro5.allegro;
import allegro5.allegro_image;
import twodee.event;
import twodee.game_state;
import twodee.state_manager;

/**
 * The Game Engine.
 */
class Engine
{
   /// Constructs the Engine
   this(uint screenWidth, uint screenHeight)
   {
      if (!al_init())
         throw new Exception("Initialization failed miserably");
      scope (failure)
         al_uninstall_system();

      if (!al_init_image_addon())
          throw new Exception("Error initializing image loaders");
      scope (failure)
         al_shutdown_image_addon();

      display_ = al_create_display(screenWidth, screenHeight);
      if (display_ is null)
         throw new Exception("Error creating display.");
      scope (failure)
         al_destroy_display(display_);

      if (!al_install_mouse())
         throw new Exception("Error initializing mouse");
      scope (failure)
         al_uninstall_mouse();

      if (!al_install_keyboard())
         throw new Exception("Error initializing keyboard");
      scope (failure)
         al_uninstall_keyboard();

      al_init_user_event_source(&customEventSource_);
      scope (failure)
         al_destroy_user_event_source(&customEventSource_);

      eventQueue_ = al_create_event_queue();
      if (eventQueue_ is null)
         throw new Exception("Error creating event queue.");
      scope (failure)
         al_destroy_event_queue(eventQueue_);

      al_register_event_source(eventQueue_,
                               al_get_display_event_source(display_));
      al_register_event_source(eventQueue_, al_get_mouse_event_source());
      al_register_event_source(eventQueue_, al_get_keyboard_event_source());
      al_register_event_source(eventQueue_, &customEventSource_);

      stateManager_ = new StateManager(this);
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
         tickEvent.user.type = TWODEE_EVENT_TICK;
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
