/**
 * The game engine.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.engine;

import allegro5.allegro;
import allegro5.allegro_image;


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

   }

   /// Destroys the Engine
   ~this()
   {
      if (display_ !is null)
         al_destroy_display(display_);

      al_shutdown_image_addon();

      al_uninstall_system();
   }

   /// The one and only display (window) where we show things.
   private ALLEGRO_DISPLAY* display_;
}
