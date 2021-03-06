/**
 * FewDee's "Canned Updaters" example.
 *
 * Canned updaters are a handy way to do things like smoothly moving things
 * around the screen or smoothly changing their sizes or colors.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
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
   al_run_allegro(
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
      // interfaces (like 'Positionable', 'Rotatable' and 'Colorable') on which
      // the canned updaters actuate.
      auto spriteType = new SpriteType(64, 64, bitmap);
      spriteType.setCenter(32, 32);
      auto sprite = new Sprite(spriteType);
      sprite.x = WIDTH/2.0;
      sprite.y = HEIGHT/2.0;

      // Updater functions are a bit naïve, in the sense that they don't know
      // about each other. If two updater functions are active at the same time,
      // trying to update the same variable, they'll "fight" for controlling the
      // object, which will be subject of erratic behavior. To avoid this,
      // before adding a new canned updater for a certain attribute, we'll
      // remove any previous canned updater working on the same attribute. The
      // following variables store the ID of the current updater for each
      // attribute we are modifying (well, not necessarily the "current", since
      // it may have already finished execution). They are initialized with
      // 'InvalidUpdaterFuncID', which is a value garanteed to never conflict
      // with a real updater ID. (Notice that it is safe to try to remove an
      // updater function that is already finished.)
      UpdaterFuncID currentPositionUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentOpacityUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentBaseColorUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentRGBAUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentScaleUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentRotationUpdater = InvalidUpdaterFuncID;

      // And now, add lots of event handlers. Canned updaters will be added in
      // response to key presses.
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

               // Position updaters
               case ALLEGRO_KEY_1:
               {
                  // This is how we create a canned updater (in this case, an
                  // updater that will update the position of an object that
                  // implements the 'Positionable' interface). It just a
                  // function call, which D's UFCS (Unified Function Call
                  // Syntax) makes look like an 'Updater's method call.
                  //
                  // So what parameters are needed? The first one is the object
                  // to be updated (here, 'sprite'). Then, come the target value
                  // the property in question (in this case, we pass two
                  // numbers, 30.0 and 30.0, which are the coordinates of the
                  // desired destination). The next parameter is the total
                  // amount of time that the transition from the current to the
                  // target value will take (typically this is in seconds, but
                  // it really depends on the notion of time of the 'Updater'
                  // being used.) The last parameter is a function that will be
                  // used to create the interpolators that will do the actual
                  // interpolation; the easiest thing to do is just to use
                  // 'interpolatorMaker()' passing the desired type of
                  // interpolator (here, we are using linear interpolation).
                  updater.remove(currentPositionUpdater);
                  currentPositionUpdater = updater.addPositionUpdater(
                     sprite, 30.0, 30.0, 3.5,
                     interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_Q:
               {
                  // Just like above, but using a quadratic interpolator that
                  // eases in and out.
                  updater.remove(currentPositionUpdater);
                  currentPositionUpdater = updater.addPositionUpdater(
                     sprite, 600, 40, 3.5,
                     interpolatorMaker!"[t^2]");
                  break;
               }

               case ALLEGRO_KEY_A:
               {
                  // This is getting boring to comment... look at the
                  // 'interpolatorMaker()' docs if you need to know what
                  // "elastic]" or something like that means.
                  updater.remove(currentPositionUpdater);
                  currentPositionUpdater = updater.addPositionUpdater(
                     sprite, 530, 410, 6.0,
                     interpolatorMaker!"elastic]");
                  break;
               }

               case ALLEGRO_KEY_Z:
               {
                  updater.remove(currentPositionUpdater);
                  currentPositionUpdater = updater.addPositionUpdater(
                     sprite, 55, 430, 2.0,
                     interpolatorMaker!"[bounce");
                  break;
               }

               // Opacity updaters
               case ALLEGRO_KEY_2:
               {
                  // Now we are using opacity canned interpolators, which
                  // interpolates the translucency of an object. This works as
                  // in the case of the position canned updaters, but we need to
                  // pass just one number as the target value (1.0, in this
                  // case).
                  updater.remove(currentOpacityUpdater);
                  currentOpacityUpdater = updater.addOpacityUpdater(
                     sprite, 1.0, 2.0,
                     interpolatorMaker!"t^2]");
                  break;
               }

               case ALLEGRO_KEY_W:
               {
                  updater.remove(currentOpacityUpdater);
                  currentOpacityUpdater = updater.addOpacityUpdater(
                     sprite, 0.66, 2.0,
                     interpolatorMaker!"[circle");
                  break;
               }

               case ALLEGRO_KEY_S:
               {
                  updater.remove(currentOpacityUpdater);
                  currentOpacityUpdater = updater.addOpacityUpdater(
                     sprite, 0.33, 2.0,
                     interpolatorMaker!"t^5]");
                  break;
               }

               case ALLEGRO_KEY_X:
               {
                  updater.remove(currentOpacityUpdater);
                  currentOpacityUpdater = updater.addOpacityUpdater(
                     sprite, 0.0, 2.0,
                     interpolatorMaker!"[exp]");
                  break;
               }

               // Base Color updaters
               case ALLEGRO_KEY_3:
               {
                  // Nothing really surprising when using base color canned
                  // interpolators. The only different thing is that we need to
                  // pass the RGB color components as the target value. Which
                  // makes sense, right?
                  immutable float[3] baseColor = [ 1.0, 1.0, 1.0 ];

                  updater.remove(currentBaseColorUpdater);

                  currentBaseColorUpdater = updater.addBaseColorUpdater(
                     sprite, baseColor, 2.0,
                     interpolatorMaker!"[t^3");
                  break;
               }

               case ALLEGRO_KEY_E:
               {
                  immutable float[3] baseColor = [ 1.0, 0.0, 0.0 ];

                  updater.remove(currentBaseColorUpdater);

                  currentBaseColorUpdater = updater.addBaseColorUpdater(
                     sprite, baseColor, 2.0,
                     interpolatorMaker!"sin]");
                  break;
               }

               case ALLEGRO_KEY_D:
               {
                  immutable float[3] baseColor = [ 0.2, 0.2, 1.0 ];

                  updater.remove(currentBaseColorUpdater);

                  currentBaseColorUpdater = updater.addBaseColorUpdater(
                     sprite, baseColor, 2.0,
                     interpolatorMaker!"[t^4]");
                  break;
               }

               case ALLEGRO_KEY_C:
               {
                  immutable float[3] baseColor = [ 0.1, 0.9, 0.3 ];

                  updater.remove(currentBaseColorUpdater);

                  currentBaseColorUpdater = updater.addBaseColorUpdater(
                     sprite, baseColor, 2.0,
                     interpolatorMaker!"[exp");
                  break;
               }

               // RGBA updaters
               case ALLEGRO_KEY_4:
               {
                  // Again, nothing really surprising when using RGBA canned
                  // interpolators. Just pass an 'ALLEGRO_COLOR' as parameter.
                  immutable rgba = al_map_rgba_f(1.0, 1.0, 1.0, 1.0);

                  updater.remove(currentRGBAUpdater);

                  currentRGBAUpdater = updater.addRGBAUpdater(
                     sprite, rgba, 2.0, interpolatorMaker!"[t^5]");
                  break;
               }

               case ALLEGRO_KEY_R:
               {
                  immutable rgba = al_map_rgba_f(0.5, 0.5, 0.0, 0.5);

                  updater.remove(currentRGBAUpdater);

                  currentRGBAUpdater = updater.addRGBAUpdater(
                     sprite, rgba, 2.0, interpolatorMaker!"exp]");
                  break;
               }

               case ALLEGRO_KEY_F:
               {
                  immutable rgba = al_map_rgba_f(0.25, 0.25, 0.25, 0.5);

                  updater.remove(currentRGBAUpdater);

                  currentRGBAUpdater = updater.addRGBAUpdater(
                     sprite, rgba, 2.0, interpolatorMaker!"[sin");
                  break;
               }

               case ALLEGRO_KEY_V:
               {
                  immutable rgba = al_map_rgba_f(0.3, 0.0, 0.3, 0.0);

                  updater.remove(currentRGBAUpdater);

                  currentRGBAUpdater = updater.addRGBAUpdater(
                     sprite, rgba, 2.0, interpolatorMaker!"[t^3]");
                  break;
               }

               // Scale updaters
               case ALLEGRO_KEY_5:
               {
                  // Now we are updating the object scale. We pass two numbers
                  // as target (1.0, 1.0), which represent the scale on both
                  // axes.
                  updater.remove(currentScaleUpdater);
                  currentScaleUpdater = updater.addScaleUpdater(
                     sprite, 1.0, 1.0, 2.0,
                     interpolatorMaker!"bounce]");
                  break;
               }

               case ALLEGRO_KEY_T:
               {
                  updater.remove(currentScaleUpdater);
                  currentScaleUpdater = updater.addScaleUpdater(
                     sprite, 0.5, 0.5, 2.0,
                     interpolatorMaker!"[t^3]");
                  break;
               }

               case ALLEGRO_KEY_G:
               {
                  updater.remove(currentScaleUpdater);
                  currentScaleUpdater = updater.addScaleUpdater(
                     sprite, 1.7, -0.8, 2.0,
                     interpolatorMaker!"[t^4");
                  break;
               }

               case ALLEGRO_KEY_B:
               {
                  updater.remove(currentScaleUpdater);
                  currentScaleUpdater = updater.addScaleUpdater(
                     sprite, 1.8, 1.8, 2.0,
                     interpolatorMaker!"[back");
                  break;
               }

               // Rotation updaters
               case ALLEGRO_KEY_6:
               {
                  // And here we begin to use rotation canned updaters. A single
                  // target value is passed (the rotation angle, in radians;
                  // increasing the value makes the object rotate in the
                  // clockwise direction).
                  updater.remove(currentRotationUpdater);
                  currentRotationUpdater = updater.addRotationUpdater(
                     sprite, 0.0, 2.0,
                     interpolatorMaker!"[back]");
                  break;
               }

               case ALLEGRO_KEY_Y:
               {
                  updater.remove(currentRotationUpdater);
                  currentRotationUpdater = updater.addRotationUpdater(
                     sprite, PI, 2.0,
                     interpolatorMaker!"[elastic]");
                  break;
               }

               case ALLEGRO_KEY_H:
               {
                  updater.remove(currentRotationUpdater);
                  currentRotationUpdater = updater.addRotationUpdater(
                     sprite, -PI, 2.0,
                     interpolatorMaker!"[circle]");
                  break;
               }

               case ALLEGRO_KEY_N:
               {
                  updater.remove(currentRotationUpdater);
                  currentRotationUpdater = updater.addRotationUpdater(
                     sprite, 5*PI, 2.0,
                     interpolatorMaker!"sin]");
                  break;
               }

               // Default
               default:
                  break; // do nothing
            }
         });

      // Draw! We just clear the screen and draw the sprite, which manages its
      // own state (position, rotation, color...).
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
      run(() => !exitPlease);

      // Clean the one resource we used, since we didn't use the
      // 'ResourceManager'
      bitmap.free();

      // We're done!
      return 0;
   });
}
