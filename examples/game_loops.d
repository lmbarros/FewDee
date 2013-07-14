/**
 * An example showing how to use the different main game loops.
 */

import std.stdio;
import fewdee.all;

// There are just minor differences between using one or another of the game
// loops provided by FewDee (or even using a custom main loop). So, instead of
// having lots of examples that look a lot like each other, we use conditional
// compilation directives ('version') to select which main loop will be
// used. You can change the selected loop below and recompile to see the
// different game loops in action.

version = FewDee_runWithConstantDrawAndTickRates;
// version = FewDee_runWithVariableDrawAndTickRates;
// version = FewDee_runWithFixedTickRateAndMaximumDrawRate;
// version = FewDee_customLoop;


void main()
{
   // Start the engine.
   scope crank = new fewdee.engine.Crank();

   // When this is set to 'true', we'll exit the main loop.
   bool exitPlease = false;

   // Quit if ESC is pressed
   EventManager.addHandler(
      ALLEGRO_EVENT_KEY_DOWN,
      delegate(in ref ALLEGRO_EVENT event)
      {
         if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
            exitPlease = true;
      });

   // Handle tick events. We'll simply print a message to the console telling
   // this tick's delta time and the equivalent ticks per second (TPS).
   EventManager.addHandler(
      FEWDEE_EVENT_TICK,
      delegate(in ref ALLEGRO_EVENT event)
      {
         const dt = event.user.deltaTime;
         writefln("Tick, deltaTime = %s (=%s TPS)", dt, 1.0/dt);
      });

   // Handle draw events. We simply clear the screen and print the same kind of
   // information as we did for tick events.
   EventManager.addHandler(
      FEWDEE_EVENT_DRAW,
      delegate(in ref ALLEGRO_EVENT event)
      {
         al_clear_to_color(al_map_rgb(127, 127, 255));

         const dt = event.user.deltaTime;
         writefln("Draw, deltaTime = %s (=%s FPS)", dt, 1.0/dt);
      });

   // Create a display
   DisplayManager.createDisplay("main");

   // Now, what everyone was expecting: the main game loops! (I'll not tell all
   // the details about them here; check the documentation!)
   //
   // Notice that, in addition to the loop versions shown here, FewDee provides
   // handy overloads for those using the 'StateManager'. You may want to check
   // those out, too!
   //
   // And there is also a simple 'Engine.run()', which is simply an alias to
   // 'runWithVariableDrawAndTickRates()'.

   // All main loops take as parameter a delegate which is used to detect when
   // to exit the loop. Here we define the function used for that purpose. (For
   // such a simple function, passing a lambda would be a good choice; other
   // examples do just that.)
   bool keepRunning()
   {
      return !exitPlease;
   }

   // Some loop implementations try to keep a constant tick rate. However, when
   // running in slower hardware, they may not be able to keep with the desired
   // pace. In these cases, the loop will keep running, but slower than
   // expected.
   //
   // In order to give you an opportunity to do something about this, you can
   // pass to the these loops a delegate that will be called whenever we lag
   // behind the desired rate. This is the purpose of the function below.
   //
   // This function takes two arguments. The first one, 'tickTime' tells how
   // long was the previous tick, in seconds (that is, the time elapsed from the
   // previous tick to the current one); it allows you to determine how slower
   // than the expected you are going. The second parameter, 'totalTime' is the
   // time, in seconds, elapsed since some arbitrary point in time; it allows
   // you to ignore too frequent calls to the handler.
   //
   // In this case, our handler simply prints some information to the
   // console. In real code, if you decide to use a "running behind handler",
   // you should probably use it do something to lower the work load, or tell
   // the user that the program is running slower than expected.
   void runningBehindHandler(double tickTime, double totalTime)
   {
      writefln("We are running behind! Tick time was %s, current time is %s",
               tickTime, totalTime);
   }

   // The real loops begin here...
   version (FewDee_runWithConstantDrawAndTickRates)
   {
      // This loop generates "draw" and "tick" events at the same constant
      // rates, so you'll experience constant FPS (frames per second) and TPS
      // (ticks per second). The "running behind handler" will be called if the
      // computer running the code is not fast enough to maintain the desired
      // frame/tick rate.

      enum desiredFPS = 30.0; // also the desired ticks per second!

      Engine.runWithConstantDrawAndTickRates(
         &keepRunning, desiredFPS, &runningBehindHandler);
   }
   else version (FewDee_runWithVariableDrawAndTickRates)
   {
      // This loop generates "draw" and "tick" events as fast as possible, but
      // the intervals between draws/ticks will vary as the workload varies.
      Engine.runWithVariableDrawAndTickRates(&keepRunning);
   }
   else version (FewDee_runWithFixedTickRateAndMaximumDrawRate)
   {
      // This loop generates "tick" events at a fixed rate ('desiredTPS'), but
      // draws as fast as possible. Just keep in mind that, in the simplest
      // usage, even though the frame rate is technically as high as possible,
      // the real frame rate will not be greater than the tick rate, because the
      // same frames will be rendered multiple times if the game state is not
      // updated between different "draw" events. State prediction via
      // interpolation may be a solution to this (given that you know the tick
      // rate, and the draw handler receives as parameter the time elapsed since
      // the last draw, you can estimate how much time elapsed since the last
      // time the game state was updated).
      enum desiredTPS = 60.0;
      enum maxFrameSkip = 5;
      Engine.runWithFixedTickRateAndMaximumDrawRate(
         &keepRunning, desiredTPS, maxFrameSkip, &runningBehindHandler);
   }
   else version (FewDee_customLoop)
   {
      // And this shows how to wire up your own custom main game
      // loop. Basically, you simply need to call
      // 'EventManager.triggerTickEvent()' and 'EventManager.triggerDrawEvent()'
      // to generate, respectively, tick and draw events.
      //
      // In the specific loop we implement here, we simply run as fast as we
      // can, pretending that the interval between draw and tick events is
      // fixed at 1/30s.

      while(!exitPlease)
      {
         enum fakeInterval = 1.0 / 30.0;
         EventManager.triggerTickEvent(fakeInterval);
         EventManager.triggerDrawEvent(fakeInterval);
      }
   }
   else
   {
      assert(
         false,
         "Please enable one of the 'version's at the top of this example");
   }
}
