/**
 * FewDee's "List Monitors" example.
 *
 * This example simply prints information about all monitors found in the
 * system.
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;

void main()
{
   scope crank = new Crank();
   const monitors = DisplayManager.monitors;

   writefln("Number of monitors: %s", monitors.length);

   foreach (i, monitor; monitors)
   {
      writefln("
   Monitor %s:
      Left: %s
      Top: %s
      Width: %s
      Height: %s\n", i, monitor.left, monitor.top, monitor.width, monitor.height);
   }
}
