/**
 * Various means to interpolate between two values (AKA "easing").
 *
 * The functions provided here interpolate between floating point numbers. If
 * you want to interpolate more concrete things, like the position or color of
 * an object, or the volume of a sound sample, take a look at module $(D
 * fewdee.canned_updaters); it may be just what you need.
 *
 * Authors: Leandro Motta Barros, based on C code originally written by Warren
 *    Moore (which was licensed under the Do What The Fuck You Want To Public
 *    License, version 2).
 *
 * See_Also: https://github.com/warrenm/AHEasing, http://robertpenner.com/easing
 */

module fewdee.interpolators;

import std.math;


/**
 * A type representing a function (er, delegate) used to interpolate between two
 * values.
 *
 * The function takes a single parameter, $(D t), which is the desired
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
 * A generic interpolator maker interface (a delegate).
 *
 * An interpolator maker is a function that returns an $(D Interpolator).
 *
 * All interpolator makers are implemented as functions that have exactly this
 * same signature.
 */
public alias Interpolator delegate(double from, double to, double duration)
   GenericInterpolatorMakerDelegate_t;



/**
 * Creates and returns an $(D Interpolator).
 *
 * This is $(I the) way to create one of the provided interpolators
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
 * used to create $(D Interpolator)s).
 *
 * This is $(I the) way to create a maker of one of the provided interpolators.
 *
 * Parameters:
 *    type = This specifies what type of interpolator is desired. The possible
 *       values are the same as in the $(D interpolator()) function.
 *
 * See_also: interpolator
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
      return toDelegate(&makeBackInInterpolator);
   else static if (type == "back]")
      return toDelegate(&makeBackOutInterpolator);
   else static if (type == "[back]")
      return toDelegate(&makeBackInOutInterpolator);
   else static if (type == "[bounce")
      return toDelegate(&makeBounceInInterpolator);
   else static if (type == "bounce]")
      return toDelegate(&makeBounceOutInterpolator);
   else static if (type == "[bounce]")
      return toDelegate(&makeBounceInOutInterpolator);
   else static if (type == "[elastic")
      return toDelegate(&makeElasticInInterpolator);
   else static if (type == "elastic]")
      return toDelegate(&makeElasticOutInterpolator);
   else static if (type == "[elastic]")
      return toDelegate(&makeElasticInOutInterpolator);
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
private Interpolator
makeLinearInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p) + from;
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
private Interpolator
makeQuadraticInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p * p) + from;
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
private Interpolator
makeQuadraticOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (-(p * (p - 2))) + from;
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
private Interpolator
makeQuadraticInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
         return c * (2 * p * p) + from;
      else
         return c * ((-2 * p * p) + (4 * p) - 1) + from;
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
private Interpolator
makeCubicInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p * p * p) + from;
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
private Interpolator
makeCubicOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      immutable f = p - 1;
      return c * (f * f * f + 1) + from;
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
private Interpolator
makeCubicInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
      {
         return c * (4 * p * p * p) + from;
      }
      else
      {
         immutable f = ((2 * p) - 2);
         return c * (0.5 * f * f * f + 1) + from;
      }
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
private Interpolator
makeQuarticInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p * p * p * p) + from;
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
private Interpolator
makeQuarticOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      immutable f = p - 1;
      return c * (f * f * f * (1 - p) + 1) + from;
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
private Interpolator
makeQuarticInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
      {
         return c * (8 * p * p * p * p) + from;
      }
      else
      {
         immutable f = p - 1;
         return c * (-8 * f * f * f * f + 1) + from;
      }
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
private Interpolator
makeQuinticInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p * p * p * p * p) + from;
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
private Interpolator
makeQuinticOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      immutable f = p - 1;
      return c * (f * f * f * f * f + 1) + from;
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
private Interpolator
makeQuinticInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
      {
         return c * (16 * p * p * p * p * p) + from;
      }
      else
      {
         immutable f = (2 * p) - 2;
         return c * (0.5 * f * f * f * f * f + 1) + from;
      }
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
private Interpolator
makeSineInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (sin((p - 1) * PI_2) + 1) + from;
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
private Interpolator
makeSineOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (sin(p * PI_2)) + from;
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
private Interpolator
makeSineInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (0.5 * (1 - cos(p * PI))) + from;
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
private Interpolator
makeCircleInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      immutable p = t / duration;
      return c * (1 - sqrt(1 - (p * p))) + from;
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
private Interpolator
makeCircleOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      immutable p = t / duration;
      return c * (sqrt((2 - p) * p)) + from;
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
private Interpolator
makeCircleInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t <= 0)
         return from;

      if (t >= duration)
         return to;

      immutable p = t / duration;

      if (p < 0.5)
         return c * (0.5 * (1 - sqrt(1 - 4 * (p * p)))) + from;
      else
         return c * (0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)) + from;
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
private Interpolator
makeExponentialInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * ((p == 0.0) ? p : pow(2, 10 * (p - 1))) + from;
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
private Interpolator
makeExponentialOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * ((p == 1.0) ? p : 1 - pow(2, -10 * p)) + from;
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
private Interpolator
makeExponentialInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      if (t == 0)
         return from;

      if (t == duration)
         return to;

      immutable p = t / duration;

      if (p < 0.5)
         return c * (0.5 * pow(2, (20 * p) - 10)) + from;
      else
         return c * (-0.5 * pow(2, (-20 * p) + 10) + 1) + from;
   };
}


/**
 * Returns a Back interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeBackInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (p * p * p - p * sin(p * PI)) + from;
   };
}


/**
 * Returns a Back interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeBackOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      immutable f = 1 - p;
      return c * (1 - (f * f * f - f * sin(f * PI))) + from;
   };
}


/**
 * Returns a Back interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeBackInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
      {
         immutable f = 2 * p;
         return c * (0.5 * (f * f * f - f * sin(f * PI))) + from;
      }
      else
      {
         immutable f = 1 - (2 * p - 1);
         return c * (0.5 * (1 - (f * f * f - f * sin(f * PI))) + 0.5) + from;
      }
   };
}


/// Helper function used internally by Bounce interpolators.
private pure nothrow double bounceHelper(double p)
{
   if (p < 4/11.0)
      return (121 * p * p) / 16.0;
   else if (p < 8/11.0)
      return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
   else if (p < 9/10.0)
      return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
   else
      return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
}


/**
 * Returns a Bounce interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeBounceInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (1 - bounceHelper(1 - p)) + from;
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
private Interpolator
makeBounceOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (bounceHelper(p)) + from;
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
private Interpolator
makeBounceInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
         return c * (1 - bounceHelper(1 - (p*2))) + from;
      else
         return c * (bounceHelper(p * 2 - 1)) + from;
   };
}


/**
 * Returns an Elastic interpolator that eases in.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeElasticInInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (sin(13 * PI_2 * p) * pow(2, 10 * (p - 1))) + from;
   };
}


/**
 * Returns an Elastic interpolator that eases out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeElasticOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;
      return c * (sin(-13 * PI_2 * (p + 1)) * pow(2, -10 * p) + 1) + from;
   };
}


/**
 * Returns an Elastic interpolator that eases in and out.
 *
 * Parameters:
 *    from = The starting value.
 *    to = The target value.
 *    duration = The duration of the interpolation.
 */
private Interpolator
makeElasticInOutInterpolator(double from, double to, double duration)
{
   immutable c = to - from;

   return delegate(t)
   {
      immutable p = t / duration;

      if (p < 0.5)
      {
         return c
            * (0.5 * sin(13 * PI_2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1)))
            + from;
      }
      else
      {
         return c
            * (0.5 * (sin(-13 * PI_2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2))
            + from;
      }
   };
}
