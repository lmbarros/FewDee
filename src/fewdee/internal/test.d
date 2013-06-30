/**
 * Testing tools.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.internal.test;

import core.exception;
import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.string;


/**
 * Checks whether two values ($(D A) and $(D b)) are "close enough" to each
 * other.
 *
 * "Close enough" is defined by the $(D epsilon) parameter. If the absolute
 * difference between $(D A) and $(D b) is less or equals to $(D epsilon *
 * min(a,b)), then they are considered close enough.
 */
void assertClose(T)(T a, T b, T epsilon = 0.01,
                    string msg = null,
                    string file = __FILE__,
                    size_t line = __LINE__)
{
   immutable tolerance = epsilon * min(a, b);
   immutable diff = abs(a - b);

   if (diff > tolerance)
   {
      immutable tail = msg.empty ? "." : ": " ~ msg;

      throw new AssertError(
         format("assertClose failed: difference between %s and %s (= %s) is "
                "larger than the tolerance (%s)%s",
                a, b, diff, tolerance, tail),
         file,
         line);
   }
}
