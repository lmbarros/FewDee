/**
 * A dummy-ish main() function, just used for testing.
 *
 * When running a program liked to the FewDee library, the unit tests within the
 * library are not executed (as of DMD 2.061). So, in order to test the library,
 * we compile all FewDee sources with this additional source file, so that we
 * get an executable that actually tests the library code.
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;


void main()
{
   version (unittest)
   {
      writeln("It seems that all unit tests passed.");
   }
   else
   {
      static assert(false, "Must compile this with unit tests enabled!");
   }
}
