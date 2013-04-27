/**
 * Various means to interpolate between two values.
 *
 * Authors: Leandro Motta Barros, based on Action Script code originally written
 *     by Robert Penner.
 *
 * License: MIT license. (Robert Penner's original code was under a three-clause
 *    BSD license.)
 *
 * See_Also: http://robertpenner.com/easing
 */

module fewdee.interpolators;

import std.math;


/**
 * A type representing a function (er, delegate) used to interpolate between two
 * values. The function takes a single parameter, t, which is the desired
 * "time". It returns the interpolated value at time t.
 *
 * The t parameter shall normally range between 0 and the requested
 * duration. Values out of this range are always acceptable and sometimes have
 * useful behavior (for example, passing increasing t values with a Sine
 * interpolator produces values oscillating between the two extremes.)
 *
 * For most interpolators, the return value will be in the range between the two
 * requested extremes as long as t is between zero and the duration. A few
 * interpolators, like the Elastic, produces values out of this "expected"
 * range. Most interpolators will return values out of the expected range if
 * they are passed a t parameter out of the zero-to-duration interval.
 */
public alias double delegate(double t) Interpolator_t;


/**
 * A generic interpolator maker interface (a delegate). Most interpolator makers
 * are implemented as functions that have exactly this same signature. However,
 * some interpolators (elastic and back interpolators, as I write this) accept
 * some extra parameters, and thus have a different interface. For these
 * nonstandard interpolator makers, there are adapters, which return one
 * delegate of this type.
 */
public alias Interpolator_t delegate(double from, double to, double duration)
   GenericInterpolatorMakerDelegate_t;



/**
 * Creates and returns an interpolator. This is the easiest way to create one of
 * the provided interpolators, and should probably be the best choice for most
 * uses. This interface has just one shortcoming: it doesn't provide a way to
 * specify the special parameters accepted by the "back" and "elastic"
 * interpolators (the default value for these parameters will be used).
 *
 * Parameters:
 *    type = This specifies what type of interpolator is desired. The general
 *       string format should be "[#" (easing in), "#]" (easing out) or "[#]"
 *       (both easing in and out). The exception is the linear interpolator,
 *       which doesn't accept brackets. "#" must be replaced by the desired
 *       interpolator type, which can be "t", "linear", "t^2", "quadratic",
 *       "t^3", "cubic", "t^4", "quartic", "t^5", "quintic", "sin", "sine",
 *       "circle", "exp", "back", "bounce" or "elastic". (Notice that many of
 *       these are synonyms, like "t" and "linear", or "sin" and "sine".)
 *    from = The starting interpolation value.
 *    to = The ending interpolation value.
 *    duration = The interpolation duration. In other words, the returned
 *       interpolator will interpolate from "from" to "to", as its independent
 *       parameter varies from 0.0 to "duration".
 */
Interpolator_t
interpolator(string type)(double from, double to, double duration = 1.0)
{
   static if (type == "t" || type == "linear")
      return MakeLinearInterpolator(from, to, duration);
   else static if (type == "[t^2" || type == "[quadratic")
      return MakeQuadraticInInterpolator(from, to, duration);
   else static if (type == "t^2]" || type == "quadratic]")
      return MakeQuadraticOutInterpolator(from, to, duration);
   else static if (type == "[t^2]" || type == "[quadratic]")
      return MakeQuadraticInOutInterpolator(from, to, duration);
   else static if (type == "[t^3" || type == "[cubic")
      return MakeCubicInInterpolator(from, to, duration);
   else static if (type == "t^3]" || type == "cubic]")
      return MakeCubicOutInterpolator(from, to, duration);
   else static if (type == "[t^3]" || type == "[cubic]")
      return MakeCubicInOutInterpolator(from, to, duration);
   else static if (type == "[t^4" || type == "[quartic")
      return MakeQuarticInInterpolator(from, to, duration);
   else static if (type == "t^4]" || type == "quartic]")
      return MakeQuarticOutInterpolator(from, to, duration);
   else static if (type == "[t^4]" || type == "[quartic]")
      return MakeQuarticInOutInterpolator(from, to, duration);
   else static if (type == "[t^5" || type == "[quintic")
      return MakeQuinticInInterpolator(from, to, duration);
   else static if (type == "t^5]" || type == "quintic]")
      return MakeQuinticOutInterpolator(from, to, duration);
   else static if (type == "[t^5]" || type == "[quintic]")
      return MakeQuinticInOutInterpolator(from, to, duration);
   else static if (type == "[sin" || type == "[sine")
      return MakeSineInInterpolator(from, to, duration);
   else static if (type == "sin]" || type == "sine]")
      return MakeSineOutInterpolator(from, to, duration);
   else static if (type == "[sin]" || type == "[sine]")
      return MakeSineInOutInterpolator(from, to, duration);
   else static if (type == "[circle")
      return MakeCircleInInterpolator(from, to, duration);
   else static if (type == "circle]")
      return MakeCircleOutInterpolator(from, to, duration);
   else static if (type == "[circle]")
      return MakeCircleInOutInterpolator(from, to, duration);
   else static if (type == "[exp")
      return MakeExponentialInInterpolator(from, to, duration);
   else static if (type == "exp]")
      return MakeExponentialOutInterpolator(from, to, duration);
   else static if (type == "[exp]")
      return MakeExponentialInOutInterpolator(from, to, duration);
   else static if (type == "[back")
      return MakeBackInInterpolator(from, to, duration);
   else static if (type == "back]")
      return MakeBackOutInterpolator(from, to, duration);
   else static if (type == "[back]")
      return MakeBackInOutInterpolator(from, to, duration);
   else static if (type == "[bounce")
      return MakeBounceInInterpolator(from, to, duration);
   else static if (type == "bounce]")
      return MakeBounceOutInterpolator(from, to, duration);
   else static if (type == "[bounce]")
      return MakeBounceInOutInterpolator(from, to, duration);
   else static if (type == "[elastic")
      return MakeElasticInInterpolator(from, to, duration);
   else static if (type == "elastic]")
      return MakeElasticOutInterpolator(from, to, duration);
   else static if (type == "[elastic]")
      return MakeElasticInOutInterpolator(from, to, duration);
   else
      static assert(false, "Invalid interpolator type string: " ~ type);
}


/**
 * Creates and returns an interpolator maker (that is, a function that can be
 * used to create interpolators). This is the easiest way to create a maker of
 * one of the provided interpolators, and should probably be the best choice for
 * most uses. This interface has just one shortcoming: it doesn't provide a way
 * to specify the special parameters accepted by the "back" and "elastic"
 * interpolators (the default value for these parameters will be used).
 *
 * Parameters:
 *    type = This specifies what type of interpolator is desired. The possible
 *       values are the same as in the interpolator() function.
 */
GenericInterpolatorMakerDelegate_t interpolatorMaker(string type)()
{
   import std.functional;

   static if (type == "t" || type == "linear")
      return toDelegate(&MakeLinearInterpolator);
   else static if (type == "[t^2" || type == "[quadratic")
      return toDelegate(&MakeQuadraticInInterpolator);
   else static if (type == "t^2]" || type == "quadratic]")
      return toDelegate(&MakeQuadraticOutInterpolator);
   else static if (type == "[t^2]" || type == "[quadratic]")
      return toDelegate(&MakeQuadraticInOutInterpolator);
   else static if (type == "[t^3" || type == "[cubic")
      return toDelegate(&MakeCubicInInterpolator);
   else static if (type == "t^3]" || type == "cubic]")
      return toDelegate(&MakeCubicOutInterpolator);
   else static if (type == "[t^3]" || type == "[cubic]")
      return toDelegate(&MakeCubicInOutInterpolator);
   else static if (type == "[t^4" || type == "[quartic")
      return toDelegate(&MakeQuarticInInterpolator);
   else static if (type == "t^4]" || type == "quartic]")
      return toDelegate(&MakeQuarticOutInterpolator);
   else static if (type == "[t^4]" || type == "[quartic]")
      return toDelegate(&MakeQuarticInOutInterpolator);
   else static if (type == "[t^5" || type == "[quintic")
      return toDelegate(&MakeQuinticInInterpolator);
   else static if (type == "t^5]" || type == "quintic]")
      return toDelegate(&MakeQuinticOutInterpolator);
   else static if (type == "[t^5]" || type == "[quintic]")
      return toDelegate(&MakeQuinticInOutInterpolator);
   else static if (type == "[sin" || type == "[sine")
      return toDelegate(&MakeSineInInterpolator);
   else static if (type == "sin]" || type == "sine]")
      return toDelegate(&MakeSineOutInterpolator);
   else static if (type == "[sin]" || type == "[sine]")
      return toDelegate(&MakeSineInOutInterpolator);
   else static if (type == "[circle")
      return toDelegate(&MakeCircleInInterpolator);
   else static if (type == "circle]")
      return toDelegate(&MakeCircleOutInterpolator);
   else static if (type == "[circle]")
      return toDelegate(&MakeCircleInOutInterpolator);
   else static if (type == "[exp")
      return toDelegate(&MakeExponentialInInterpolator);
   else static if (type == "exp]")
      return toDelegate(&MakeExponentialOutInterpolator);
   else static if (type == "[exp]")
      return toDelegate(&MakeExponentialInOutInterpolator);
   else static if (type == "[back")
      return MakeGenericBackInInterpolatorMaker();
   else static if (type == "back]")
      return MakeGenericBackOutInterpolatorMaker();
   else static if (type == "[back]")
      return MakeGenericBackInOutInterpolatorMaker();
   else static if (type == "[bounce")
      return toDelegate(&MakeBounceInInterpolator);
   else static if (type == "bounce]")
      return toDelegate(&MakeBounceOutInterpolator);
   else static if (type == "[bounce]")
      return toDelegate(&MakeBounceInOutInterpolator);
   else static if (type == "[elastic")
      return MakeGenericElasticInInterpolatorMaker();
   else static if (type == "elastic]")
      return MakeGenericElasticOutInterpolatorMaker();
   else static if (type == "[elastic]")
      return MakeGenericElasticInOutInterpolatorMaker();
   else
      static assert(false, "Invalid interpolator type string: " ~ type);
}



/**
 * Returns a Linear interpolator.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeLinearInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * t / duration + from;
   };
}


/**
 * Returns a Quadratic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuadraticInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * (t /= duration) * t + from;
   };
}


/**
 * Returns a Quadratic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuadraticOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return -c * (t /= duration) * (t - 2) + from;
   };
}


/**
 * Returns a Quadratic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuadraticInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * t * t + from;
      return -c / 2 * ((--t) * (t - 2) - 1) + from;
   };
}


/**
 * Returns a Cubic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCubicInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * (t /= duration) * t * t + from;
   };
}


/**
 * Returns a Cubic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCubicOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * ((t = t / duration - 1) * t * t + 1) + from;
   };
}


/**
 * Returns a Cubic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCubicInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * t * t * t + from;
      return c / 2 * ((t -= 2) * t * t + 2) + from;
    };
}


/**
 * Returns a Quartic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuarticInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * (t /= duration) * t * t * t + from;
   };
}


/**
 * Returns a Quartic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuarticOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return -c * ((t = t / duration - 1) * t * t * t - 1) + from;
   };
}


/**
 * Returns a Quartic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuarticInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * t * t * t * t + from;
      return -c / 2 * ((t -= 2) * t * t * t - 2) + from;
   };
}


/**
 * Returns a Quintic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuinticInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * (t /= duration) * t * t * t * t + from;
   };
}


/**
 * Returns a Quintic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuinticOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * ((t = t / duration - 1) * t * t * t * t + 1) + from;
   };
}


/**
 * Returns a Quintic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeQuinticInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * t * t * t * t * t + from;
      return c / 2 * ((t -= 2) * t * t * t * t + 2) + from;

   };
}


/**
 * Returns a Sine interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeSineInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return -c * cos(t / duration * (PI / 2)) + c + from;
   };
}


/**
 * Returns a Sine interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeSineOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * sin(t / duration * (PI / 2)) + from;
   };
}


/**
 * Returns a Sine interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeSineInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return -c / 2 * (cos(PI * t / duration) - 1) + from;
   };
}


/**
 * Returns a Circle interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCircleInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      return -c * (sqrt(1 - (t /= duration) * t) - 1) + from;
   };
}


/**
 * Returns a Circle interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCircleOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      return c * sqrt(1 - (t = t / duration - 1) * t) + from;
   };
}


/**
 * Returns a Circle interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeCircleInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      if ((t /= duration / 2) < 1)
         return -c / 2 * (sqrt(1 - t * t) - 1) + from;

      return c / 2 * (sqrt(1 - (t -= 2) * t) + 1) + from;
   };
}


/**
 * Returns an Exponential interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeExponentialInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return (t == 0)
         ? from
         : c * 2 ^^ (10 * (t / duration - 1)) + from;
   };
}


/**
 * Returns an Exponential interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeExponentialOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return (t == duration)
         ? from + c
         : c * (-2 ^^ (-10 * t / duration) + 1) + from;
   };
}


/**
 * Returns an Exponential interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeExponentialInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t == 0)
         return from;

      if (t == duration)
         return from + c;

      if ((t /= duration / 2) < 1)
         return c / 2 * 2 ^^ (10 * (t - 1)) + from;

      return c / 2 * (-2 ^^ (-10 * --t) + 2) + from;
   };
}


/**
 * Returns a Back interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the more the function will overshot
 *       the [from, to] range.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBackInInterpolator(double from, double to, double amplitude = 1.70158,
                       double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c * (t /= duration) * t * ((amplitude + 1) * t - amplitude) + from;
   };
}


/**
 * Returns a Back interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the more the function will overshot
 *       the [from, to] range.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBackOutInterpolator(double from, double to, double amplitude = 1.70158,
                        double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c
         * ((t = t / duration - 1) * t * ((amplitude + 1) * t + amplitude) + 1)
         + from;
   };
}


/**
 * Returns a Back interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the more the function will overshot
 *       the [from, to] range.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBackInOutInterpolator(double from, double to, double amplitude = 1.70158,
                          double duration = 1.0)
{
   immutable c = to - from;
   immutable s = amplitude * 1.525;

   return delegate(t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * (t * t * ((s + 1) * t - s)) + from;

      return c / 2 * ((t -= 2) * t * ((s + 1) * t + s) + 2) + from;
   };
}


/// Helper to create a generic interpolator from a "back in interpolator".
GenericInterpolatorMakerDelegate_t
MakeGenericBackInInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return MakeBackInInterpolator(from, to, amplitude, duration);
   };
}


/// Helper to create a generic interpolator from a "back out interpolator".
GenericInterpolatorMakerDelegate_t
MakeGenericBackOutInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return MakeBackOutInterpolator(from, to, amplitude, duration);
   };
}


/// Helper to create a generic interpolator from a "back in/out interpolator".
GenericInterpolatorMakerDelegate_t
MakeGenericBackInOutInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return MakeBackInOutInterpolator(from, to, amplitude, duration);
   };
}


/// Helper function used by Bounce interpolators.
private double
bounceInterpolatorHelper(double t, double from, double c, double duration)
{
   if ((t /= duration) < (1 / 2.75))
      return c * (7.5625 * t * t) + from;
   else if (t < (2 / 2.75))
      return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + from;
   else if (t < (2.5 / 2.75))
      return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + from;
   else
      return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + from;
}


/**
 * Returns a Bounce interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBounceInInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return bounceInterpolatorHelper(t, from, c, duration);
   };
}


/**
 * Returns a Bounce interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBounceOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      return c - bounceInterpolatorHelper(duration - t, 0, c, duration) + from;
   };
}


/**
 * Returns a Bounce interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeBounceInOutInterpolator(double from, double to, double duration = 1.0)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t < duration/2)
      {
         return bounceInterpolatorHelper(t * 2, 0, c, duration) * .5 + from;
      }
      else
      {
         return bounceInterpolatorHelper(t * 2 - duration, 0, c, duration)
            * .5 + c * .5 + from;
      }
   };
}


/**
 * Returns an Elastic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the larger the "ripples" will be. Only
 *       values larger than the difference between from and to will make the
 *       "ripples" actually larger. When passing a NaN (the default), this is
 *       initialized with the difference between from and to.
 *    period = The closer this value is to zero, the more "ripples" will be.
 *       When passing a NaN (the default), a pleasant-looking value (which is
 *       about a third of the duration) will be used.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeElasticInInterpolator(double from, double to, double amplitude = double.nan,
                          double period = double.nan, double duration = 1.0)
{
   immutable c = to - from;
   double s;

   if (isnan(period))
      period = duration * .3;

   if (isnan(amplitude) || amplitude < abs(c))
   {
      amplitude = c;
      s = period / 4;
   }
   else
   {
      s = period / (2 * PI) * asin(c / amplitude);
   }

   return delegate(t)
   {
      if (t == 0)
         return from;

      if ((t /= duration) == 1)
         return from + c;

      return -(amplitude * 2 ^^ (10 * (t -= 1))
               * sin((t * duration - s) * (2 * PI) / period))
         + from;
   };
}


/**
 * Returns an Elastic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the larger the "ripples" will be. Only
 *       values larger than the difference between from and to will make the
 *       "ripples" actually larger. When passing a NaN (the default), this is
 *       initialized with the difference between from and to.
 *    period = The closer this value is to zero, the more "ripples" will be.
 *       When passing a NaN (the default), a pleasant-looking value (which is
 *       about a third of the duration) will be used.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeElasticOutInterpolator(double from, double to,
                           double amplitude = double.nan,
                           double period = double.nan, double duration = 1.0)
{
   immutable c = to - from;
   double s;

   if (isnan(period))
      period = duration * .3;

   if (isnan(amplitude) || amplitude < abs(c))
   {
      amplitude = c;
      s = period / 4;
   }
   else
   {
      s = period / (2 * PI) * asin (c / amplitude);
   }

   return delegate(t)
   {
      if (t == 0)
         return from;

      if ((t /= duration) == 1)
         return from + c;

      return amplitude * 2 ^^ (-10 * t)
         * sin((t * duration - s) * (2 * PI) / period)
         + c + from;
   };
}


/**
 * Returns an Elastic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    amplitude = The larger this value, the larger the "ripples" will be. Only
 *       values larger than the difference between from and to will make the
 *       "ripples" actually larger. When passing a NaN (the default), this is
 *       initialized with the difference between from and to.
 *    period = The closer this value is to zero, the more "ripples" will be.
 *       When passing a NaN (the default), a pleasant-looking value (which is
 *       about a third of the duration) will be used.
 *    duration = The duration of the interpolation.
 */
public Interpolator_t
MakeElasticInOutInterpolator(double from, double to,
                             double amplitude = double.nan,
                             double period = double.nan, double duration = 1.0)
{
   immutable c = to - from;
   double s;

   if (isnan(period))
      period = duration * (.3 * 1.5);

   if (isnan(amplitude) || amplitude < abs(c))
   {
      amplitude = c;
      s = period / 4;
   }
   else
   {
      s = period / (2 * PI) * asin(c / amplitude);
   }

   return delegate(t)
   {
      if (t == 0)
         return from;

      if ((t /= duration / 2) == 2)
         return from + c;

      if (t < 1)
      {
         return -.5
            * (amplitude
               * 2 ^^ (10 * (t -= 1))
               * sin((t * duration - s) * (2 * PI) / period))
            + from;
      }

      return amplitude
         * pow(2, -10 * (t -= 1))
         * sin((t * duration - s) * (2 * PI) / period)
         * .5
         + c + from;
   };
}


/// Helper to create a generic interpolator from an "elastic in interpolator".
GenericInterpolatorMakerDelegate_t
MakeGenericElasticInInterpolatorMaker(double amplitude = double.nan,
                                      double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return MakeElasticOutInterpolator(from, to, amplitude, period, duration);
   };
}


/// Helper to create a generic interpolator from an "elastic out interpolator".
GenericInterpolatorMakerDelegate_t
MakeGenericElasticOutInterpolatorMaker(double amplitude = double.nan,
                                       double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return MakeElasticOutInterpolator(from, to, amplitude, period, duration);
   };
}


/**
 * Helper to create a generic interpolator from an "elastic in/out
 * interpolator".
 */
GenericInterpolatorMakerDelegate_t
MakeGenericElasticInOutInterpolatorMaker(double amplitude = double.nan,
                                         double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return MakeElasticInOutInterpolator(from, to, amplitude, period, duration);
   };
}
