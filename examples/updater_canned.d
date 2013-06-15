/**
 * FewDee's "Canned Updaters" example.
 *
 * Canned updaters are a handy way to do things like smoothly moving things
 * around the screen or smoothly changing their sizes or colors.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.functional;
import std.math;
import fewdee.all;


// We'll use these to position things on the screen.
enum WIDTH = 640;
enum HEIGHT = 480;


void main()
{
   // Start the engine
   scope crank = new fewdee.engine.Crank();

   // Canned updaters are just updater functions of the kind we add to
   // 'Updater's. They just happen to be handy because they do stuff that we
   // frequently want to do.
   scope updater = new TickBasedUpdater();

   // When this is set to 'true', we'll exit the main loop.
   bool exitPlease = false;

   // Initialize the only resource we'll use. We are not using the
   // 'ResourceManager' here, so we'll have to release the resources manually
   // when the program ends.
   auto bitmap = new Bitmap("data/white_circle.png");

   // Now create a Sprite. All updaters we'll create will operate on it,
   // modifying its properties. A 'Sprite' implements lots of interesting
   // interfaces (like 'Positionable', 'Rotatable' and 'Colorable') on which the
   // canned updaters actuate.
   auto sprite = new Sprite(64, 64, 32, 32);
   sprite.addBitmap(bitmap);
   sprite.x = WIDTH/2.0;
   sprite.y = HEIGHT/2.0;

   // And now, add lots of event handlers. Canned updaters will be added in
   // response to key presses.

   // Quit if ESC is pressed
   EventManager.addHandler(
      ALLEGRO_EVENT_KEY_DOWN,
      delegate(in ref ALLEGRO_EVENT event)
      {
         switch (event.keyboard.keycode)
         {
            case ALLEGRO_KEY_ESCAPE:
            {
               exitPlease = true;
               break;
            }

            // Position updaters
            case ALLEGRO_KEY_1:
            {
               // This is how we create a canned updater (in this case, an
               // updater that will update the position of an object that
               // implements the 'Positionable' interface). It just a function
               // call, which D's UFCS (Unified Function Call Syntax) makes look
               // like an 'Updater's method call.
               //
               // So what parameters are needed? The first one is the object to
               // be updated (here, 'sprite'). Then, come the target value the
               // property in question (in this case, we pass two numbers, 30.0
               // and 30.0, which are the coordinates of the desired
               // destination). The next parameter is the total amount of time
               // that the transition from the current to the target value will
               // take (typically this is in seconds, but it really depends on
               // the notion of time of the 'Updater' being used.) The last
               // parameter is a function that will be used to create the
               // interpolators that will do the actual interpolation; the
               // easiest thing to do is just to use 'interpolatorMaker()'
               // passing the desired type of interpolator (here, we are using
               // linear interpolation).
               updater.addPositionUpdater(
                  sprite, 30.0, 30.0, 3.5,
                  interpolatorMaker!"t");
               break;
            }

            case ALLEGRO_KEY_Q:
            {
               // Just like above, but using a quadratic interpolator that eases
               // in and out.
               updater.addPositionUpdater(
                  sprite, 600, 40, 3.5,
                  interpolatorMaker!"[t^2]");
               break;
            }

            case ALLEGRO_KEY_A:
            {
               // This is getting boring to comment... look at the
               // 'interpolatorMaker()' docs if you need to know what "elastic]"
               // or something like that means.
               updater.addPositionUpdater(
                  sprite, 530, 410, 6.0,
                  interpolatorMaker!"elastic]");
               break;
            }

            case ALLEGRO_KEY_Z:
            {
               updater.addPositionUpdater(
                  sprite, 55, 430, 2.0,
                  interpolatorMaker!"[bounce");
               break;
            }

            // Alpha updaters
            case ALLEGRO_KEY_2:
            {
               // Now we are using alpha canned interpolators, which
               // interpolates the translucency of an object. This works as in
               // the case of the position canned updaters, but we need to pass
               // just one number as the target value (1.0, in this case).
               updater.addAlphaUpdater(
                  sprite, 1.0, 2.0,
                  interpolatorMaker!"t^2]");
               break;
            }

            case ALLEGRO_KEY_W:
            {
               updater.addAlphaUpdater(
                  sprite, 0.66, 2.0,
                  interpolatorMaker!"[circle");
               break;
            }

            case ALLEGRO_KEY_S:
            {
               updater.addAlphaUpdater(
                  sprite, 0.33, 2.0,
                  interpolatorMaker!"t^5]");
               break;
            }

            case ALLEGRO_KEY_X:
            {
               updater.addAlphaUpdater(
                  sprite, 0.0, 2.0,
                  interpolatorMaker!"[exp]");
               break;
            }

            // Color updaters
            case ALLEGRO_KEY_3:
            {
               // Nothing really surprising when using color canned
               // interpolators. The only different thing is that we need to
               // pass a color as the target value. Which makes sense, right?
               immutable color =
                  al_map_rgba_f(1.0, 1.0, 1.0, 1.0);

               updater.addColorUpdater(
                  sprite, color, 2.0,
                  interpolatorMaker!"[t^3");
               break;
            }

            case ALLEGRO_KEY_E:
            {
               immutable color =
                  al_map_rgba_f(1.0, 0.0, 0.0, 0.1);

               updater.addColorUpdater(
                  sprite, color, 2.0,
                  interpolatorMaker!"sin]");
               break;
            }

            case ALLEGRO_KEY_D:
            {
               immutable color =
                  al_map_rgba_f(0.2, 0.2, 1.0, 1.0);

               updater.addColorUpdater(
                  sprite, color, 2.0,
                  interpolatorMaker!"[t^4]");
               break;
            }

            case ALLEGRO_KEY_C:
            {
               immutable color =
                  al_map_rgba_f(0.1, 0.9, 0.3, 0.9);

               updater.addColorUpdater(
                  sprite, color, 2.0,
                  interpolatorMaker!"[exp");
               break;
            }

            // Scale updaters
            case ALLEGRO_KEY_4:
            {
               // Now we are updating the object scale. We pass two numbers as
               // target (1.0, 1.0), which represent the scale on both axes.
               updater.addScaleUpdater(
                  sprite, 1.0, 1.0, 2.0,
                  interpolatorMaker!"bounce]");
               break;
            }

            case ALLEGRO_KEY_R:
            {
               updater.addScaleUpdater(
                  sprite, 0.5, 0.5, 2.0,
                  interpolatorMaker!"[t^3]");
               break;
            }

            case ALLEGRO_KEY_F:
            {
               updater.addScaleUpdater(
                  sprite, 1.7, -0.8, 2.0,
                  interpolatorMaker!"[t^4");
               break;
            }

            case ALLEGRO_KEY_V:
            {
               updater.addScaleUpdater(
                  sprite, 1.8, 1.8, 2.0,
                  interpolatorMaker!"[back");
               break;
            }

            // Rotation updaters
            case ALLEGRO_KEY_5:
            {
               // And here we begin to use rotation canned updaters. A single
               // target value is passed (the rotation angle, in radians;
               // increasing the value makes the object rotate in the clockwise
               // direction).
               updater.addRotationUpdater(
                  sprite, 0.0, 2.0,
                  interpolatorMaker!"[back]");
               break;
            }

            case ALLEGRO_KEY_T:
            {
               updater.addRotationUpdater(
                  sprite, PI, 2.0,
                  interpolatorMaker!"[elastic]");
               break;
            }

            case ALLEGRO_KEY_G:
            {
               updater.addRotationUpdater(
                  sprite, -PI, 2.0,
                  interpolatorMaker!"[circle]");
               break;
            }

            case ALLEGRO_KEY_B:
            {
               updater.addRotationUpdater(
                  sprite, 5*PI, 2.0,
                  interpolatorMaker!"sin]");
               break;
            }

            // Default
            default:
               break; // do nothing
         }
      });

   // Draw! We just clear the screen and draw the sprite, which manages its own
   // state (position, rotation, color...).
   EventManager.addHandler(
      FEWDEE_EVENT_DRAW,
      delegate(in ref ALLEGRO_EVENT event)
      {
         al_clear_to_color(al_map_rgb_f(0.1, 0.1, 0.1));
         sprite.draw();
      });

   // Create a display
   DisplayManager.createDisplay("main");

   // Run the main loop while 'exitPlease' is true.
   Engine.run(() => !exitPlease);
}
