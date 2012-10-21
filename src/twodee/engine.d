/**
 * The game engine.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.engine;

import allegro5.allegro;
import allegro5.allegro_image;
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

      if (!al_init_image_addon())
          throw new Exception("Error initializing image loaders");

      display_ = al_create_display(screenWidth, screenHeight);
      if (display_ is null)
         throw new Exception("Error creating display.");

      stateManager_ = new StateManager();
   }

   /// Destroys the Engine
   ~this()
   {
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
         double now = al_get_time();
         auto deltaTime = now - prevTime;
         prevTime = now;

         stateManager_.onTick(deltaTime);
         stateManager_.onDraw();
         al_flip_display();
      }
   }

   /// The one and only display (window) where we show things.
   private ALLEGRO_DISPLAY* display_;

   /// The object managing the game states.
   private StateManager stateManager_;
}
