/**
 * Example plotting the interpolators' graphs. Yes, you can change the
 * interpolation parameters and see the results right there.
 *
 * Authors: Leandro Motta Barros
 */

import std.conv;
import std.exception;
import std.stdio;
import fewdee.all;


immutable WIDTH = 640;
immutable HEIGHT = 480;


enum Interpolator
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


Interpolator CurrentInterpolator = Interpolator.Linear;
auto From = -10.0;
auto To = 10.0;
auto Duration = 1.0;
auto Amplitude = 2.0;
auto Period = 0.3;

Interpolator_t TheInterpolator;

void RemakeInterpolator()
{
   final switch(CurrentInterpolator)
   {
      case Interpolator.Linear:
         TheInterpolator = MakeLinearInterpolator(From, To, Duration);
         break;

      case Interpolator.QuadraticIn:
         TheInterpolator = MakeQuadraticInInterpolator(From, To, Duration);
         break;

      case Interpolator.QuadraticOut:
         TheInterpolator = MakeQuadraticOutInterpolator(From, To, Duration);
         break;

      case Interpolator.QuadraticInOut:
         TheInterpolator = MakeQuadraticInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.CubicIn:
         TheInterpolator = MakeCubicInInterpolator(From, To, Duration);
         break;

      case Interpolator.CubicOut:
         TheInterpolator = MakeCubicOutInterpolator(From, To, Duration);
         break;

      case Interpolator.CubicInOut:
         TheInterpolator = MakeCubicInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.QuarticIn:
         TheInterpolator = MakeQuarticInInterpolator(From, To, Duration);
         break;

      case Interpolator.QuarticOut:
         TheInterpolator = MakeQuarticOutInterpolator(From, To, Duration);
         break;

      case Interpolator.QuarticInOut:
         TheInterpolator = MakeQuarticInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.QuinticIn:
         TheInterpolator = MakeQuinticInInterpolator(From, To, Duration);
         break;

      case Interpolator.QuinticOut:
         TheInterpolator = MakeQuinticOutInterpolator(From, To, Duration);
         break;

      case Interpolator.QuinticInOut:
         TheInterpolator = MakeQuinticInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.SineIn:
         TheInterpolator = MakeSineInInterpolator(From, To, Duration);
         break;

      case Interpolator.SineOut:
         TheInterpolator = MakeSineOutInterpolator(From, To, Duration);
         break;

      case Interpolator.SineInOut:
         TheInterpolator = MakeSineInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.CircleIn:
         TheInterpolator = MakeCircleInInterpolator(From, To, Duration);
         break;

      case Interpolator.CircleOut:
         TheInterpolator = MakeCircleOutInterpolator(From, To, Duration);
         break;

      case Interpolator.CircleInOut:
         TheInterpolator = MakeCircleInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.ExponentialIn:
         TheInterpolator = MakeExponentialInInterpolator(From, To, Duration);
         break;

      case Interpolator.ExponentialOut:
         TheInterpolator = MakeExponentialOutInterpolator(From, To, Duration);
         break;

      case Interpolator.ExponentialInOut:
         TheInterpolator = MakeExponentialInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.BackIn:
         TheInterpolator =
            MakeBackInInterpolator(From, To, Amplitude, Duration);
         break;

      case Interpolator.BackOut:
         TheInterpolator =
            MakeBackOutInterpolator(From, To, Amplitude, Duration);
         break;

      case Interpolator.BackInOut:
         TheInterpolator =
            MakeBackInOutInterpolator(From, To, Amplitude, Duration);
         break;

      case Interpolator.BounceIn:
         TheInterpolator = MakeBounceInInterpolator(From, To, Duration);
         break;

      case Interpolator.BounceOut:
         TheInterpolator = MakeBounceOutInterpolator(From, To, Duration);
         break;

      case Interpolator.BounceInOut:
         TheInterpolator = MakeBounceInOutInterpolator(From, To, Duration);
         break;

      case Interpolator.ElasticIn:
         TheInterpolator =
            MakeElasticInInterpolator(From, To, Amplitude, Period, Duration);
         break;

      case Interpolator.ElasticOut:
         TheInterpolator =
            MakeElasticOutInterpolator(From, To, Amplitude, Period, Duration);
         break;

      case Interpolator.ElasticInOut:
         TheInterpolator =
            MakeElasticInOutInterpolator(From, To, Amplitude, Period, Duration);
         break;

      case Interpolator.Count:
         assert(false); // can't happen
   }
}

void DrawGraph()
{
   pure nothrow double convX(double x)
   {
      return x * (WIDTH/4.0) + (WIDTH/4.0);
   }

   pure nothrow double convY(double y)
   {
      return HEIGHT - (y * (HEIGHT/40.0) + (HEIGHT/2.0));
   }

   auto prevX = -1.0;
   auto prevY = TheInterpolator(-1.0);
   enum delta = 0.01;

   for (auto t = -1.0; t <= 3.0; t += delta)
   {
      auto color = al_map_rgba_f(0.9, 0.1, 0.1, 0.85);
      if (t < 0.0 + delta || t > Duration + delta)
         color = al_map_rgba_f(0.9, 0.6, 0.6, 0.85);

      auto thickness = 2.5;
      auto x1 = prevX;
      auto y1 = prevY;
      auto x2 = t;
      auto y2 = TheInterpolator(t);

      al_draw_line(convX(x1), convY(y1),
                   convX(x2), convY(y2),
                   color, thickness);

      prevX = x2;
      prevY = y2;
   }

   al_draw_filled_circle(convX(0.0), convY(From),
                         4.5, al_map_rgba_f(0.1, 0.9, 0.1, 0.9));

   al_draw_filled_circle(convX(Duration), convY(To),
                         4.5, al_map_rgba_f(0.1, 0.1, 0.9, 0.9));
}

class TheState: GameState
{
   this()
   {
      // Load the background image
      bmpBG_ = AllegroBitmap("data/interpolators_graphs_bg.png");
      enforce(bmpBG_ !is null);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });

      // Handle other keys
      addEventCallback(ALLEGRO_EVENT_KEY_CHAR,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          switch (event.keyboard.keycode)
                          {
                             // Duration
                             case ALLEGRO_KEY_D:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                   Duration -= 0.1;
                                else
                                   Duration += 0.1;

                                if (Duration < 0.1)
                                   Duration = 0.1;

                                writefln("Duration = %s", Duration);
                                RemakeInterpolator();

                                break;
                             }

                             // From
                             case ALLEGRO_KEY_F:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                   From -= 1.0;
                                else
                                   From += 1.0;

                                writefln("From = %s", From);
                                RemakeInterpolator();

                                break;
                             }

                             // To
                             case ALLEGRO_KEY_T:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                   To -= 1.0;
                                else
                                   To += 1.0;

                                writefln("To = %s", To);
                                RemakeInterpolator();

                                break;
                             }

                             // Amplitude
                             case ALLEGRO_KEY_A:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                   Amplitude -= 0.1;
                                else
                                   Amplitude += 0.1;

                                writefln("Amplitude = %s", Amplitude);
                                RemakeInterpolator();

                                break;
                             }

                             // Period
                             case ALLEGRO_KEY_P:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                   Period -= 0.1;
                                else
                                   Period += 0.1;

                                writefln("Period = %s", Period);
                                RemakeInterpolator();

                                break;
                             }

                             // Interpolator
                             case ALLEGRO_KEY_I:
                             {
                                auto mod = event.keyboard.modifiers;
                                if (mod & ALLEGRO_KEYMOD_SHIFT)
                                {
                                   if (CurrentInterpolator > 0)
                                      --CurrentInterpolator;
                                }
                                else
                                {
                                   auto limit = Interpolator.Count - 1;
                                   if (CurrentInterpolator < limit)
                                      ++CurrentInterpolator;
                                }

                                writefln("Interpolator = %s",
                                         to!string(CurrentInterpolator));
                                RemakeInterpolator();

                                break;
                             }

                             default:
                             {
                                break; // do nothing
                             }
                          }
                       });

      // Ensure we have a valid interpolator
      RemakeInterpolator();
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(255, 255, 255));
      al_draw_bitmap(bmpBG_, 0.0, 0.0, 0);
      DrawGraph();
   }

   private AllegroBitmap bmpBG_;
}

void main()
{
   scope crank = new fewdee.engine.Crank();
   fewdee.engine.run(new TheState());
}
