/**
 * FewDee's "Interpolator's Graphs" example.
 *
 * Plots the interpolators' graphs. Allows to change the interpolation
 * parameters and see the results right there.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.stdio;
import fewdee.all;


// To make our life easier, this example runs in a fixed resolution. Here are
// two manifest constants defining the desired window size. This matches the
// image we use in the background (and there are also a few other hardcoded
// values in the code, so changing these values will probably not work very
// well).
enum WIDTH = 640;
enum HEIGHT = 480;


// An enumeration with all interpolators supported by this example (which should
// be all the standard interpolators provided by FewDee, which should be all of
// Robert Penner's easing functions (http://robertpenner.com/easing).
enum InterpolatorType
{
   Linear,
   QuadraticIn, QuadraticOut, QuadraticInOut,
   CubicIn, CubicOut, CubicInOut,
   QuarticIn, QuarticOut, QuarticInOut,
   QuinticIn, QuinticOut, QuinticInOut,
   SineIn, SineOut, SineInOut,
   CircleIn, CircleOut, CircleInOut,
   ExponentialIn, ExponentialOut, ExponentialInOut,
   BackIn, BackOut, BackInOut,
   BounceIn, BounceOut, BounceInOut,
   ElasticIn, ElasticOut, ElasticInOut,
   Count,
}


// Now, let's define some global variables that will store the interpolation
// parameters that the user will be able to tweak. (Yes, globals can make a
// short example like this simpler to understand).

// This is the type of interpolator ("easing function") to use.
InterpolatorType currentInterpolator = InterpolatorType.Linear;

// The starting interpolation value.
auto from = -10.0;

// The target value, which will be reached at the end of the interpolation.
auto to = 10.0;

// All interpolators generate interpolated values as a certain variable (usually
// called "t") grows from zero to a certain value (usually 1.0). This is this
// certain value.
auto duration = 1.0;

// Interpolators in FewDee are delegates that take one parameter (the "t" value)
// and return the interpolated value. In this example, the following variable
// stores the interpolator used to draw the graphs.
Interpolator theInterpolator;

// And this is the neat "graph paper" bitmap we'll use as the background image.
Bitmap bmpBG;


// Whenever the user changes an interpolation parameter, we need to reset the
// 'theInterpolator' variable with an updated interpolator. That's what this
// function does.
//
// To create an interpolator, we call the 'interpolator()' template function.
private void remakeInterpolator()
{
   final switch (currentInterpolator) with (InterpolatorType)
   {
      // This is how we call the 'interpolator()' function. The template
      // parameter (here, "t") determines the type of interpolator that will be
      // created and returned (in this case, a linear interpolator).
      case Linear:
         theInterpolator = interpolator!"t"(from, to, duration);
         break;

      // Here, we are creating a quadratic interpolator ("t^2"), which will ease
      // in (that is the meaning of the opening square brackets).
      case QuadraticIn:
         theInterpolator = interpolator!"[t^2"(from, to, duration);
         break;

      // This is like above, but we use closing square brackets. This means that
      // the interpolator will ease out.
      case QuadraticOut:
         theInterpolator = interpolator!"t^2]"(from, to, duration);
         break;

      // And here we use both opening and closing square brackets: the
      // interpolator will ease in and out.
      case QuadraticInOut:
         theInterpolator = interpolator!"[t^2]"(from, to, duration);
         break;

      // From now on, all calls are similar... just the template parameter
      // changes. The documentation of 'interpolator()' lists all accepted
      // values, including variations -- you could "[cubic" instead of "[t^3",
      // for example.
      case CubicIn:
         theInterpolator = interpolator!"[t^3"(from, to, duration);
         break;

      case CubicOut:
         theInterpolator = interpolator!"t^3]"(from, to, duration);
         break;

      case CubicInOut:
         theInterpolator = interpolator!"[t^3]"(from, to, duration);
         break;

      case QuarticIn:
         theInterpolator = interpolator!"[t^4"(from, to, duration);
         break;

      case QuarticOut:
         theInterpolator = interpolator!"t^4]"(from, to, duration);
         break;

      case QuarticInOut:
         theInterpolator = interpolator!"[t^4]"(from, to, duration);
         break;

      case QuinticIn:
         theInterpolator = interpolator!"[t^5"(from, to, duration);
         break;

      case QuinticOut:
         theInterpolator = interpolator!"t^5]"(from, to, duration);
         break;

      case QuinticInOut:
         theInterpolator = interpolator!"[t^5]"(from, to, duration);
         break;

      case SineIn:
         theInterpolator = interpolator!"[sin"(from, to, duration);
         break;

      case SineOut:
         theInterpolator = interpolator!"sin]"(from, to, duration);
         break;

      case SineInOut:
         theInterpolator = interpolator!"[sin]"(from, to, duration);
         break;

      case CircleIn:
         theInterpolator = interpolator!"[circle"(from, to, duration);
         break;

      case CircleOut:
         theInterpolator = interpolator!"circle]"(from, to, duration);
         break;

      case CircleInOut:
         theInterpolator = interpolator!"[circle]"(from, to, duration);
         break;

      case ExponentialIn:
         theInterpolator = interpolator!"[exp"(from, to, duration);
         break;

      case ExponentialOut:
         theInterpolator = interpolator!"exp]"(from, to, duration);
         break;

      case ExponentialInOut:
         theInterpolator = interpolator!"[exp]"(from, to, duration);
         break;

      case BackIn:
         theInterpolator = interpolator!"[back"(from, to, duration);
         break;

      case BackOut:
         theInterpolator = interpolator!"back]"(from, to, duration);
         break;

      case BackInOut:
         theInterpolator = interpolator!"[back]"(from, to, duration);
         break;

      case BounceIn:
         theInterpolator = interpolator!"[bounce"(from, to, duration);
         break;

      case BounceOut:
         theInterpolator = interpolator!"bounce]"(from, to, duration);
         break;

      case BounceInOut:
         theInterpolator = interpolator!"[bounce]"(from, to, duration);
         break;

      case ElasticIn:
         theInterpolator = interpolator!"[elastic"(from, to, duration);
         break;

      case ElasticOut:
         theInterpolator = interpolator!"elastic]"(from, to, duration);
         break;

      case ElasticInOut:
         theInterpolator = interpolator!"[elastic]"(from, to, duration);
         break;

      case Count:
         assert(false); // can't happen
   }
}


// And here's the function that uses 'theTnterpolator' to draw the graphs.
private void drawGraph()
{
   // These two nested functions just translate "raw" coordinate values to
   // values that will fit nicely in our gridded background image.
   pure nothrow double convX(double x)
   {
      return x * (WIDTH/4.0) + (WIDTH/4.0);
   }

   pure nothrow double convY(double y)
   {
      return HEIGHT - (y * (HEIGHT/40.0) + (HEIGHT/2.0));
   }

   // Here we begin the actual drawing. One thing to notice is that it is OK to
   // call the interpolators passing values out of the [from, to] range. You
   // could use, for instance, a sine interpolator to make something
   // continuously and smoothly vary back and forth between two values. Or you
   // could use a linear interpolator to (linearly) extrapolate.
   auto prevX = -1.0;
   auto prevY = theInterpolator(-1.0);
   enum delta = 0.01;

   for (auto t = -1.0; t <= 3.0; t += delta)
   {
      // Use a more discrete color for the values out of the [0, duration]
      // interval.
      auto color = al_map_rgba_f(0.9, 0.1, 0.1, 0.85);
      if (t < 0.0 + delta || t > duration + delta)
         color = al_map_rgba_f(0.9, 0.6, 0.6, 0.85);

      enum thickness = 2.5;
      auto x1 = prevX;
      auto y1 = prevY;
      auto x2 = t;
      auto y2 = theInterpolator(t); // the interpolator is actually used here

      al_draw_line(convX(x1), convY(y1),
                   convX(x2), convY(y2),
                   color, thickness);

      prevX = x2;
      prevY = y2;
   }

   // Mark the "from" and "to" points in the graph.
   al_draw_filled_circle(convX(0.0), convY(from),
                         4.5, al_map_rgba_f(0.1, 0.9, 0.1, 0.9));

   al_draw_filled_circle(convX(duration), convY(to),
                         4.5, al_map_rgba_f(0.1, 0.1, 0.9, 0.9));
}



// The main function. You should now what it is :-)
void main()
{
   al_run_allegro(
   {
      // Start the engine
      scope crank = new fewdee.engine.Crank();

      // We are using the functions provided by the Allegro primitives add on,
      // so we have to initialize it.
      AllegroManager.initPrimitives();

      // Load the background image. (Since we are not using the ResourceManager,
      // we'll need to free it manually later).
      bmpBG = new Bitmap("data/interpolators_graphs_bg.png");

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Now register all the event handlers we'll need

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // Handle other keys. These just allow the user to change the interpolator
      // parameters. Nothing really interesting is done here.
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_CHAR,
         delegate(in ref ALLEGRO_EVENT event)
         {
            switch (event.keyboard.keycode)
            {
               // duration
               case ALLEGRO_KEY_D:
               {
                  auto mod = event.keyboard.modifiers;
                  if (mod & ALLEGRO_KEYMOD_SHIFT)
                     duration -= 0.1;
                  else
                     duration += 0.1;

                  if (duration < 0.1)
                     duration = 0.1;

                  writefln("duration = %s", duration);
                  remakeInterpolator();

                  break;
               }

               // from
               case ALLEGRO_KEY_F:
               {
                  auto mod = event.keyboard.modifiers;
                  if (mod & ALLEGRO_KEYMOD_SHIFT)
                     from -= 1.0;
                  else
                     from += 1.0;

                  writefln("from = %s", from);
                  remakeInterpolator();

                  break;
               }

               // to
               case ALLEGRO_KEY_T:
               {
                  auto mod = event.keyboard.modifiers;
                  if (mod & ALLEGRO_KEYMOD_SHIFT)
                     to -= 1.0;
                  else
                     to += 1.0;

                  writefln("to = %s", to);
                  remakeInterpolator();

                  break;
               }

               // Interpolator
               case ALLEGRO_KEY_I:
               {
                  auto mod = event.keyboard.modifiers;
                  if (mod & ALLEGRO_KEYMOD_SHIFT)
                  {
                     if (currentInterpolator > 0)
                        --currentInterpolator;
                  }
                  else
                  {
                     auto limit = InterpolatorType.Count - 1;
                     if (currentInterpolator < limit)
                        ++currentInterpolator;
                  }

                  writefln("Interpolator = %s", currentInterpolator);
                  remakeInterpolator();

                  break;
               }

               default:
               {
                  break; // do nothing
               }
            }
         });

      // Handle draw events. Clear all to white, draw the background, plot the
      // graph. Nothing unexpected.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(255, 255, 255));
            al_draw_bitmap(bmpBG, 0.0, 0.0, 0);
            drawGraph();
         });

      // Initialize 'theInterpolator'.
      remakeInterpolator();

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // And free the one resource we allocated in this example.
      bmpBG.free();

      // We're done!
      return 0;
   });
}
