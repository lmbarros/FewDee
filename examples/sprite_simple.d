/**
 * A simple example showing how to use sprites.
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;


void main()
{
   al_run_allegro(
   {
      // Start the engine and "accessories"
      scope crank = new fewdee.engine.Crank();
      scope updater = new TickBasedUpdater();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Initialize the only resource we'll use. This is the sprite sheet we'll
      // use with our sprites. We are not using the 'ResourceManager' here, so
      // we'll have to release this bitmap manually when the program ends.
      auto bmpStickMan = new Bitmap("data/stick_man.png");

      // First thing to do is to create a 'SpriteTemplate'. A 'SpriteTemplate'
      // contains a collection of images and a collection of animations that can
      // be shared among several sprite instances. The constructor we are using
      // here sets the size of the images used by this sprite (all images must
      // be of the same size).
      scope sptStickMan = new SpriteTemplate(64, 64);

      // Now, we add the images. Notice that all the images are actually
      // referencing the same bitmap (our sprite sheet). The two numeric
      // parameters indicate the top left corner of the image within the bitmap.
      sptStickMan.addImage(bmpStickMan, 0, 0);
      sptStickMan.addImage(bmpStickMan, 64, 0);
      sptStickMan.addImage(bmpStickMan, 128, 0);
      sptStickMan.addImage(bmpStickMan, 192, 0);
      sptStickMan.addImage(bmpStickMan, 0, 64);
      sptStickMan.addImage(bmpStickMan, 64, 64);

      // Add two animations. Each animation has a name and a set of frames. Each
      // frame contains an image index and the time, in seconds, that this frame
      // will be displayed.
      sptStickMan.addAnimation("wave",
                               SpriteTemplate.Frame(1, 0.2),
                               SpriteTemplate.Frame(2, 0.2),
                               SpriteTemplate.Frame(3, 0.2),
                               SpriteTemplate.Frame(2, 0.2),
                               SpriteTemplate.Frame(1, 0.2),
                               SpriteTemplate.Frame(0, 0.2));

      sptStickMan.addAnimation("jump",
                               SpriteTemplate.Frame(4, 0.2),
                               SpriteTemplate.Frame(0, 0.2),
                               SpriteTemplate.Frame(5, 0.2),
                               SpriteTemplate.Frame(0, 0.2),
                               SpriteTemplate.Frame(4, 0.2),
                               SpriteTemplate.Frame(0, 0.2));

      // At this point, the 'SpriteTemplate' is complete. Let's create some
      // 'Sprite's based on this template. Here they are, four stick men:
      scope sprStickMan1 = new fewdee.sprite.Sprite(sptStickMan);
      scope sprStickMan2 = new fewdee.sprite.Sprite(sptStickMan);
      scope sprStickMan3 = new fewdee.sprite.Sprite(sptStickMan);
      scope sprStickMan4 = new fewdee.sprite.Sprite(sptStickMan);

      // The first stick man will wave in a loop. Here, we add to 'updater' an
      // updater function that will update the sprite's current image as the
      // time passes. In addition to the target sprite and the animation name,
      // we pass the relative speed at which we want to play the animation (we
      // use 1.0, since we want to play at the nominal speed) and a flag
      // indicating that we want to play in loop (true).
      updater.addAnimation(sprStickMan1, "wave", 1.0, true);

      // And now, add event handlers.
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            switch (event.keyboard.keycode)
            {
               // Quit if ESC is pressed
               case ALLEGRO_KEY_ESCAPE:
               {
                  exitPlease = true;
                  break;
               }

               // If any other key is pressed, we'll make the three non-waving
               // stick men jump, at different speeds.
               default:
               {
                  // Again, we use 'addAnimation()'. We don't need to pass a
                  // 'false' parameter to indicate that we don't want to loop --
                  // that's the default. In the case of 'sprStickMan3', which
                  // will play the jump animation at its nominal speed, we don't
                  // even have to pass 1.0 for the speed -- again, that's the
                  // default.
                  //
                  // Notice that we are not doing anything to avoid playing more
                  // than one animation at once. So, if you press lots of keys,
                  // multiple simultaneous animations will interfere with each
                  // other, causing glitches.
                  updater.addAnimation(sprStickMan2, "jump", 0.75);
                  updater.addAnimation(sprStickMan3, "jump");
                  updater.addAnimation(sprStickMan4, "jump", 1.25);
                  break;
               }
            }
         });

      // Finally, set the drawing function. We simply clear the background to
      // white and draw each of the stick men, side-by-side.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(255, 255, 255));
            sprStickMan1.draw(100, 100);
            sprStickMan2.draw(150, 100);
            sprStickMan3.draw(200, 100);
            sprStickMan4.draw(250, 100);
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // Free resources (using the ResourceManager would be a good idea).
      bmpStickMan.free();

      // We're done!
      return 0;
   });
}
