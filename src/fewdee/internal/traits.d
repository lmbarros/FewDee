/**
 * Traits-like helpers for FewDee implementation.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 *
 * TODO: All the $(D static if)s used below to detect if a given type $(D
 *    isSomething) are below par; some may even be technically wrong.
 */

module fewdee.internal.traits;

import std.traits;


/**
 * Detects whether $(D T) has a $(D color) property of type $(D Color).
 *
 * These are the types considered "colorable", with which some of the canned
 * updaters are designed to work with.
 */
template isColorable(T)
{
   import fewdee.color;
   static if (hasMember!(T, "color") && is(Unqual!(typeof(T.color)) == Color))
      enum isColorable = true;
   else
      enum isColorable = false;
}

/**
 * Detects whether $(D T) has $(D x) and $(D y) properties of type $(D float).
 *
 * These are the types considered "positionable", with which some of the canned
 * updaters are designed to work with.
 */
template isPositionable(T)
{
   static if (hasMember!(T, "x") && isAssignable!(typeof(T.x), float)
              && hasMember!(T, "y") && isAssignable!(typeof(T.x), float))
   {
      enum isPositionable = true;
   }
   else
   {
      enum isPositionable = false;
   }
}


/**
 * Detects whether $(D T) has a $(D rotation) property of type $(D float).
 *
 * These are the types considered "rotatable", with which some of the canned
 * updaters are designed to work with.
 */
template isRotatable(T)
{
   static if (hasMember!(T, "rotation")
              && isAssignable!(typeof(T.rotation), float))
   {
      enum isRotatable = true;
   }
   else
   {
      enum isRotatable = false;
   }
}


/**
 * Detects whether $(D T) has $(D scaleX) and $(D scaleY) properties of type $(D
 * float).
 *
 * These are the types considered "scalable", with which some of the canned
 * updaters are designed to work with.
 */
template isScalable(T)
{
   static if (hasMember!(T, "scaleX")
              && isAssignable!(typeof(T.scaleX), float)
              && hasMember!(T, "scaleY")
              && isAssignable!(typeof(T.scaleY), float))
   {
      enum isScalable = true;
   }
   else
   {
      enum isScalable = false;
   }
}


/**
 * Detects whether $(D T) has a $(D gain) property of type $(D float).
 *
 * These are the types considered "gainable" (a terrible name, by the way), with
 * which some of the canned updaters are designed to work with.
 */
template isGainable(T)
{
   static if (hasMember!(T, "gain") && isAssignable!(typeof(T.gain), float))
   {
      enum isGainable = true;
   }
   else
   {
      enum isGainable = false;
   }
}


/**
 * Detects whether $(D T) has a $(D speed) property of type $(D float).
 *
 * These are the types considered "speedable" (a terrible name, by the way),
 * with which some of the canned updaters are designed to work with.
 */
template isSpeedable(T)
{
   static if (hasMember!(T, "speed") && isAssignable!(typeof(T.gain), float))
   {
      enum isSpeedable = true;
   }
   else
   {
      enum isSpeedable = false;
   }
}


/**
 * Detects whether $(D T) has a $(D balance) property of type $(D float).
 *
 * These are the types considered "balanceable" (a terrible name, by the way),
 * with which some of the canned updaters are designed to work with.
 */
template isBalanceable(T)
{
   static if (hasMember!(T, "balance") && isAssignable!(typeof(T.gain), float))
   {
      enum isBalanceable = true;
   }
   else
   {
      enum isBalanceable = false;
   }
}
