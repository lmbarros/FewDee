/**
 * Various means to interpolate between two values (AKA "easing").
 *
 * The functions provided here interpolate between floating point numbers. If
 * you want to interpolate more concrete things, like the position or color of
 * an object, take a look at module $(D fewdee.canned_updaters); it may be just
 * what you need.
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
 * values. The function takes a single parameter, $(D t), which is the desired
 * "time". It returns the interpolated value at time $(D t).
 *
 * The $(D t) parameter shall normally range between 0 and the requested
 * duration. Values out of this range are always acceptable and sometimes have
 * useful behavior (for example, passing increasingly larger $(D t) values with
 * a Sine interpolator produces values oscillating between the two extremes.)
 *
 * For most interpolators, the return value will be in the range between the two
 * requested extremes as long as $(D t) is between zero and the duration. A few
 * interpolators, like the Elastic, produces values out of this "expected"
 * range. Most interpolators will return values out of the expected range if
 * they are passed a $(D t) parameter out of the zero-to-duration interval.
 */
public alias double delegate(double t) Interpolator;


/**
 * A generic interpolator maker interface (a delegate). Most interpolator makers
 * are implemented as functions that have exactly this same signature. However,
 * some interpolators (Elastic and Back interpolators, as I write this) accept
 * some extra parameters, and thus have a different interface. For these
 * nonstandard interpolator makers, there are adapters, which return one
 * delegate of this type.
 */
public alias Interpolator delegate(double from, double to, double duration)
   GenericInterpolatorMakerDelegate_t;



/**
 * Creates and returns an interpolator. This is the easiest way to create one of
 * the provided interpolators, and should probably be the best choice for most
 * uses. This interface has just one shortcoming: it doesn't provide a way to
 * specify the special parameters accepted by the Back and Elastic interpolators
 * (the default value for these parameters will be used).
 *
 * Parameters:
 *    type = This specifies what type of interpolator is desired. The general
 *       string format should be $(D "[#") (easing in), $(D "#]") (easing out)
 *       or $(D "[#]") (both easing in and out). The exception is the linear
 *       interpolator, which doesn't accept brackets. $(D "#") must be replaced
 *       by the desired interpolator type, which can be $(D "t"), $(D "linear"),
 *       $(D "t^2"), $(D "quadratic"), $(D "t^3"), $(D "cubic"), $(D "t^4"), $(D
 *       "quartic"), $(D "t^5"), $(D "quintic"), $(D "sin"), $(D "sine"), $(D
 *       "circle"), $(D "exp"), $(D "back"), $(D "bounce") or $(D
 *       "elastic"). (Notice that many of these are synonyms, like $(D "t") and
 *       $(D "linear"), or $(D "sin") and $(D "sine").)
 *    from = The starting interpolation value.
 *    to = The ending interpolation value.
 *    duration = The interpolation duration. In other words, the returned
 *       interpolator will interpolate from $(D from) to $(D to), as its
 *       independent parameter varies from $(D 0.0) to $(D duration).
 */
public Interpolator
interpolator(string type)(double from, double to, double duration = 1.0)
{
   static if (type == "t" || type == "linear")
      return makeLinearInterpolator(from, to, duration);
   else static if (type == "[t^2" || type == "[quadratic")
      return makeQuadraticInInterpolator(from, to, duration);
   else static if (type == "t^2]" || type == "quadratic]")
      return makeQuadraticOutInterpolator(from, to, duration);
   else static if (type == "[t^2]" || type == "[quadratic]")
      return makeQuadraticInOutInterpolator(from, to, duration);
   else static if (type == "[t^3" || type == "[cubic")
      return makeCubicInInterpolator(from, to, duration);
   else static if (type == "t^3]" || type == "cubic]")
      return makeCubicOutInterpolator(from, to, duration);
   else static if (type == "[t^3]" || type == "[cubic]")
      return makeCubicInOutInterpolator(from, to, duration);
   else static if (type == "[t^4" || type == "[quartic")
      return makeQuarticInInterpolator(from, to, duration);
   else static if (type == "t^4]" || type == "quartic]")
      return makeQuarticOutInterpolator(from, to, duration);
   else static if (type == "[t^4]" || type == "[quartic]")
      return makeQuarticInOutInterpolator(from, to, duration);
   else static if (type == "[t^5" || type == "[quintic")
      return makeQuinticInInterpolator(from, to, duration);
   else static if (type == "t^5]" || type == "quintic]")
      return makeQuinticOutInterpolator(from, to, duration);
   else static if (type == "[t^5]" || type == "[quintic]")
      return makeQuinticInOutInterpolator(from, to, duration);
   else static if (type == "[sin" || type == "[sine")
      return makeSineInInterpolator(from, to, duration);
   else static if (type == "sin]" || type == "sine]")
      return makeSineOutInterpolator(from, to, duration);
   else static if (type == "[sin]" || type == "[sine]")
      return makeSineInOutInterpolator(from, to, duration);
   else static if (type == "[circle")
      return makeCircleInInterpolator(from, to, duration);
   else static if (type == "circle]")
      return makeCircleOutInterpolator(from, to, duration);
   else static if (type == "[circle]")
      return makeCircleInOutInterpolator(from, to, duration);
   else static if (type == "[exp")
      return makeExponentialInInterpolator(from, to, duration);
   else static if (type == "exp]")
      return makeExponentialOutInterpolator(from, to, duration);
   else static if (type == "[exp]")
      return makeExponentialInOutInterpolator(from, to, duration);
   else static if (type == "[back")
      return makeBackInInterpolator(from, to, duration);
   else static if (type == "back]")
      return makeBackOutInterpolator(from, to, duration);
   else static if (type == "[back]")
      return makeBackInOutInterpolator(from, to, duration);
   else static if (type == "[bounce")
      return makeBounceInInterpolator(from, to, duration);
   else static if (type == "bounce]")
      return makeBounceOutInterpolator(from, to, duration);
   else static if (type == "[bounce]")
      return makeBounceInOutInterpolator(from, to, duration);
   else static if (type == "[elastic")
      return makeElasticInInterpolator(from, to, duration);
   else static if (type == "elastic]")
      return makeElasticOutInterpolator(from, to, duration);
   else static if (type == "[elastic]")
      return makeElasticInOutInterpolator(from, to, duration);
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
 *       values are the same as in the $(D interpolator()) function.
 */
public GenericInterpolatorMakerDelegate_t interpolatorMaker(string type)()
{
   import std.functional;

   static if (type == "t" || type == "linear")
      return toDelegate(&makeLinearInterpolator);
   else static if (type == "[t^2" || type == "[quadratic")
      return toDelegate(&makeQuadraticInInterpolator);
   else static if (type == "t^2]" || type == "quadratic]")
      return toDelegate(&makeQuadraticOutInterpolator);
   else static if (type == "[t^2]" || type == "[quadratic]")
      return toDelegate(&makeQuadraticInOutInterpolator);
   else static if (type == "[t^3" || type == "[cubic")
      return toDelegate(&makeCubicInInterpolator);
   else static if (type == "t^3]" || type == "cubic]")
      return toDelegate(&makeCubicOutInterpolator);
   else static if (type == "[t^3]" || type == "[cubic]")
      return toDelegate(&makeCubicInOutInterpolator);
   else static if (type == "[t^4" || type == "[quartic")
      return toDelegate(&makeQuarticInInterpolator);
   else static if (type == "t^4]" || type == "quartic]")
      return toDelegate(&makeQuarticOutInterpolator);
   else static if (type == "[t^4]" || type == "[quartic]")
      return toDelegate(&makeQuarticInOutInterpolator);
   else static if (type == "[t^5" || type == "[quintic")
      return toDelegate(&makeQuinticInInterpolator);
   else static if (type == "t^5]" || type == "quintic]")
      return toDelegate(&makeQuinticOutInterpolator);
   else static if (type == "[t^5]" || type == "[quintic]")
      return toDelegate(&makeQuinticInOutInterpolator);
   else static if (type == "[sin" || type == "[sine")
      return toDelegate(&makeSineInInterpolator);
   else static if (type == "sin]" || type == "sine]")
      return toDelegate(&makeSineOutInterpolator);
   else static if (type == "[sin]" || type == "[sine]")
      return toDelegate(&makeSineInOutInterpolator);
   else static if (type == "[circle")
      return toDelegate(&makeCircleInInterpolator);
   else static if (type == "circle]")
      return toDelegate(&makeCircleOutInterpolator);
   else static if (type == "[circle]")
      return toDelegate(&makeCircleInOutInterpolator);
   else static if (type == "[exp")
      return toDelegate(&makeExponentialInInterpolator);
   else static if (type == "exp]")
      return toDelegate(&makeExponentialOutInterpolator);
   else static if (type == "[exp]")
      return toDelegate(&makeExponentialInOutInterpolator);
   else static if (type == "[back")
      return makeGenericBackInInterpolatorMaker();
   else static if (type == "back]")
      return makeGenericBackOutInterpolatorMaker();
   else static if (type == "[back]")
      return makeGenericBackInOutInterpolatorMaker();
   else static if (type == "[bounce")
      return toDelegate(&makeBounceInInterpolator);
   else static if (type == "bounce]")
      return toDelegate(&makeBounceOutInterpolator);
   else static if (type == "[bounce]")
      return toDelegate(&makeBounceInOutInterpolator);
   else static if (type == "[elastic")
      return makeGenericElasticInInterpolatorMaker();
   else static if (type == "elastic]")
      return makeGenericElasticOutInterpolatorMaker();
   else static if (type == "[elastic]")
      return makeGenericElasticInOutInterpolatorMaker();
   else
      static assert(false, "Invalid interpolator type string: " ~ type);
}


//
// From now on, what we have is a slightly more powerful interface (can set
// those parameters that exist only for "back" and "elastic" interpolators), but
// which is also much less uniform and a bit more verbose. Most users will
// probably be happier simply using interpolator() and interpolatorMaker().
//


/**
 * Returns a Linear interpolator.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
public Interpolator
makeLinearInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuadraticInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuadraticOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuadraticInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCubicInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCubicOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCubicInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuarticInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuarticOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuarticInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuinticInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuinticOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeQuinticInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeSineInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeSineOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeSineInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCircleInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCircleOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeCircleInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeExponentialInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeExponentialOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeExponentialInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeBackInInterpolator(double from, double to, double amplitude = 1.70158,
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
public Interpolator
makeBackOutInterpolator(double from, double to, double amplitude = 1.70158,
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
public Interpolator
makeBackInOutInterpolator(double from, double to, double amplitude = 1.70158,
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


/**
 * Creates a generic interpolator maker for a "Back In" interpolator, which is
 * usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeBackInInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericBackInInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return makeBackInInterpolator(from, to, amplitude, duration);
   };
}


/**
 * Creates a generic interpolator maker for s "Back Out" interpolator, which is
 * usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeBackOutInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericBackOutInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return makeBackOutInterpolator(from, to, amplitude, duration);
   };
}


/**
 * Creates a generic interpolator maker for a "Back In/Out" interpolator, which
 * is usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeBackInOutInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericBackInOutInterpolatorMaker(double amplitude = 1.70158)
{
   return delegate(from, to, duration)
   {
      return makeBackInOutInterpolator(from, to, amplitude, duration);
   };
}


/// Helper function used internally by Bounce interpolators.
private pure nothrow double
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
public Interpolator
makeBounceInInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeBounceOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeBounceInOutInterpolator(double from, double to, double duration = 1.0)
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
public Interpolator
makeElasticInInterpolator(double from, double to, double amplitude = double.nan,
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
 *       values larger than the difference between $(D from) and $(D to) will
 *       make the "ripples" actually larger. When passing a NaN (the default),
 *       this is initialized with the difference between $(D from) and $(D to).
 *    period = The closer this value is to zero, the more "ripples" will be.
 *       When passing a NaN (the default), a pleasant-looking value (which is
 *       about a third of the duration) will be used.
 *    duration = The duration of the interpolation.
 */
public Interpolator
makeElasticOutInterpolator(double from, double to,
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
 *       values larger than the difference between $(D from) and $(D to) will
 *       make the "ripples" actually larger. When passing a NaN (the default),
 *       this is initialized with the difference between $(D from) and $(D to).
 *    period = The closer this value is to zero, the more "ripples" will be.
 *       When passing a NaN (the default), a pleasant-looking value (which is
 *       about a third of the duration) will be used.
 *    duration = The duration of the interpolation.
 */
public Interpolator
makeElasticInOutInterpolator(double from, double to,
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


/**
 * Creates a generic interpolator maker for an "Elastic In" interpolator, which
 * is usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeElasticInInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericElasticInInterpolatorMaker(double amplitude = double.nan,
                                      double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return makeElasticOutInterpolator(from, to, amplitude, period, duration);
   };
}


/**
 * Creates a generic interpolator maker for an "Elastic Out" interpolator, which
 * is usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeElasticOutInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericElasticOutInterpolatorMaker(double amplitude = double.nan,
                                       double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return makeElasticOutInterpolator(from, to, amplitude, period, duration);
   };
}


/**
 * Creates a generic interpolator maker for an "Elastic In/Out" interpolator,
 * which is usually created through a nonstandard interface.
 *
 * In other words, this function adapts the interface of $(D
 * makeElasticInOutInterpolator()) to a $(D GenericInterpolatorMakerDelegate_t).
 */
public GenericInterpolatorMakerDelegate_t
makeGenericElasticInOutInterpolatorMaker(double amplitude = double.nan,
                                         double period = double.nan)
{
   return delegate(from, to, duration)
   {
      return makeElasticInOutInterpolator(from, to, amplitude, period, duration);
   };
}
