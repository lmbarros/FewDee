/**
 * Various means to interpolate between two values.
 *
 * Authors: Robert Penner (author of the original Action Script code) and
 *    Leandro Motta Barros (D version).
 *
 * License: Three-clause BSD license. (This is different from most code in this
 *    library, which is under the MIT license.)
 *
 * See_Also: http://robertpenner.com/easing
 */

module twodee.interpolators;

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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
   {
      return -c * ( t/= duration) * (t - 2) + from;
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

   return delegate(double t)
   {
      if ( (t /= duration / 2) < 1)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
   {
      if ((t /= duration / 2) < 1)
         return c / 2 * (t * t * ((s + 1) * t - s)) + from;

      return c / 2 * ((t -= 2) * t * ((s + 1) * t + s) + 2) + from;
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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

   return delegate(double t)
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



// TERMS OF USE - EASING EQUATIONS
//
// Open source under the BSD License.
//
// Copyright © 2001 Robert Penner
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//     Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//     Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//     Neither the name of the author nor the names of contributors may be used
//     to endorse or promote products derived from this software without
//     specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
