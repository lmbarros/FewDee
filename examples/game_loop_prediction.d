/**
 * FewDee's "Game Loop Prediction" example.
 *
 * This example shows how to use a $(D runWithFixedTickRateAndMaximumDrawRate())
 * main game loop, using a low tick rate, and predicting the positions of
 * objects when drawing them between ticks. It also shows how to use a $(D
 * DrawBasedUpdater), which also enables smooth animations with a low tick rate,
 * but is useful in different situations.
 *
 * See_also: http://www.koonsolo.com/news/dewitters-gameloop/ (Look for "The
 * Need for Interpolation" and "Interpolation and Prediction".)
 *
 * Authors: Leandro Motta Barros
 */


import std.math;
import fewdee.all;

// One possible way to setup your main game loop is as follows:
//
// 1) Use a slowish tick rate, so that you update the game state only, say, 20
//    or 25 times per second. Oftentimes, it doesn't really makes much
//    difference to process events and update the game state more often than
//    that, so you can save resources by limiting the tick rate.
//
// 2) Draw as fast as you can, even if this means having many draw events
//    between two consecutive ticks events. This way, you'll have animations
//    running as smoothly as possible.
//
// Looks like the best of two worlds (save resources in ticks, but keeps frame
// rate high). Even better: FewDee provides this kind of loop out of the box,
// via runWithFixedTickRateAndMaximumDrawRate()! There is just one problem. The
// game state is updated in tick events, right? What happens if you draw five
// times between two consecutive ticks? We'll, you are drawing the same state,
// so you get five frames that look exactly the same! From the user point of
// view, your frame rate is limited by the tick rate. Not good.
//
// One way to circumvent this problem is to use prediction. Suppose you have a
// moving object. You know its position, as set by the most recent tick
// event. You also happen to know what its speed was by the time of the previous
// tick. If, when drawing, you also knew how much time elapsed since the last
// tick, you could assume that the object speed didn't change and predict its
// current position. FewDee actually passes to draw events the time elapsed
// since the last tick event, so this is all very feasible.
//
// Another way to have different frames drawn between two ticks is to use a
// 'DrawBasedUpdater', which works just like a 'TickBasedUpdater', but is based
// on draw events. This is particularly handy to update user interface elements,
// or perhaps even to update sprite animations. You'll not want to use a
// 'DrawBasedUpdater' to update the game state: that's what a 'TickBasedUpdater'
// is for! (Notice that updating sprite animations is actually kind of a gray
// zone: the current frame of a sprite could be considered part of the game
// state, so perhaps they should belong to a 'TickBasedUpdater'. Also, sprite
// animations are rarely very smooth, so perhaps those 2o or 25 ticks per second
// are enough to drive the sprite animation. Use your judgment.)
//
// So, what about this example? In this example, we'll have three objects of
// different colors moving in circles around the screen. The red and blue
// objects will always have the same position; their 'x' and 'y' properties will
// always be updated at the same time (in "tick events"), and to the same
// values. Since we'll use a very slow tick rate, their positions will chance
// only a few times per second.
//
// Now, the tick rate will be slow, but the draw rate will be high (as fast as
// the hardware can support, in fact). And when drawing, the objects will be
// drawn at different positions.The red one will be drawn exactly at its 'x' and
// 'y' coordinates; since the position is updated infrequently, its movement
// will be jumpy. The blue object, on the other hand, will be drawn at an
// estimated position (that is, the position that object would most likely be at
// if its state were being updated); hence, its movement will be smooth.
//
// In this example, our "estimation" of the blue circle position will be much
// better than in real life. In fact, I quoted "estimation" because it isn't
// really an estimation: we'll know exactly where it would be. In real
// applications, things like random numbers and user input preclude us to have
// perfect estimations. But in real life the tick rate would be at least around
// 20 or 25 ticks per second -- much higher than the one we are using here, so
// visual artifacts would probably be a non issue.
//
// What about the third object? Well, it will be green, and its position will be
// updated by a 'DrawBasedUpdater' (let's pretend that the green object is just
// some kind of eye candy that isn't really related with the game state). Its
// animation will be smooth, too.


// We'll use these to position things on the screen.
enum WIDTH = 640;
enum HEIGHT = 480;


// As said above, our objects will move in circles. This is the function that
// computes the object position at a given time.
pure void getObjectPosition(double t, out double x, out double y)
{
   enum cx = WIDTH / 2.0;
   enum cy = HEIGHT / 2.0;
   enum r = HEIGHT * 0.4;

   x = cx + r * cos(t);
   y = cy + r * sin(t);
}


// Here we go...
void main()
{
   al_run_allegro(
   {
      // Start the engine, create an Updater
      scope crank = new fewdee.engine.Crank();
      scope updater = new DrawBasedUpdater();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Initialize the only resource we'll use. We are not using the
      // 'ResourceManager' here, so we'll have to release the resources manually
      // when the program ends.
      auto bitmap = new Bitmap("data/white_circle.png");

      // Now create two Sprites.
      auto spriteType = new SpriteType(64, 64, bitmap);
      spriteType.setCenter(32, 32);

      auto redObject = new Sprite(spriteType);
      redObject.color = al_map_rgb_f(1.0, 0.0, 0.0);

      auto blueObject = new Sprite(spriteType);
      blueObject.color = al_map_rgb_f(0.0, 0.0, 1.0);

      auto greenObject = new Sprite(spriteType);
      greenObject.color = al_map_rgb_f(0.0, 1.0, 0.0);

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // We'll want to remember the time of the last tick event.
      double lastTickTime;

      // When receiving tick events, update the positions of the red and blue
      // objects.
      EventManager.addHandler(
         FEWDEE_EVENT_TICK,
         delegate(in ref ALLEGRO_EVENT event)
         {
            double x, y;
            getObjectPosition(event.user.totalTime, x, y);

            redObject.x = x;
            redObject.y = y;

            blueObject.x = x;
            blueObject.y = y;

            // Remember the time of this tick
            lastTickTime = event.user.totalTime;
         });

      // Make our green object move as the 'DrawBasedUpdater' calls the updater
      // function. Since the 'DrawBasedUpdater' is based on the (very frequent)
      // draw events, animation will be smooth. (You'll notice it is moving
      // behind the other objects, but this shouldn't matter -- it's just
      // eye candy, independent of the game state, right?)
      auto totalTime = 0.0;
      updater.add(
         delegate(double deltaTime)
         {
            totalTime += deltaTime;

            double x, y;
            getObjectPosition(totalTime, x, y);
            greenObject.x = x;
            greenObject.y = y;

            return true;
         });

      // Draw!
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb_f(0.8, 0.95, 0.85));

            // Drawing the red and the green objects is as easy enough, since we
            // are drawing them at their "real positions".
            redObject.draw();
            greenObject.draw();

            // But drawing the blue object is a bit harder, since we'll draw it
            // in a predicted position. First, we need to obtain the predicted
            // position. The draw event gets a 'timeSinceTick' parameter that
            // exists just for this reason. (In this made up example, we could
            // use the 'totalTime' parameter instead, but let's use
            // 'timeSinceTick', which should be more useful in real-world
            // examples.)
            double predX, predY;
            getObjectPosition(
               lastTickTime + event.user.timeSinceTick, predX, predY);

            // Now that we "predicted" where the blue object is likely to be, we
            // need to draw it. Using 'Sprite.draw()' will not do, because this
            // would get the object draw at its current, real position -- we
            // want it at the predicted position! No problem: we just call
            // Sprite.drawOverriding(), which allow us to override some (or all)
            // of the sprite properties.
            blueObject.drawOverriding(predX, predY);
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true. Notice that we are asking
      // for only 2 ticks per second.
      runWithFixedTickRateAndMaximumDrawRate(() => !exitPlease, 2.0);

      // Clean the one resource we used, since we didn't use the
      // 'ResourceManager'
      bitmap.free();

      // We're done!
      return 0;
   });
}
