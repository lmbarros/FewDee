/**
 * FewDee's "Display Manager Info" example.
 *
 * This example simply prints information about all monitors and display modes
 * found in the system.
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;

void main()
{
   al_run_allegro(
   {
      scope crank = new Crank();
      const monitors = DisplayManager.monitors;

      writefln("Number of monitors: %s", monitors.length);

      foreach (i, monitor; monitors)
      {
         writefln("   Monitor %s: %sx%s pixels, at %s,%s", i,
                  monitor.width, monitor.height, monitor.left, monitor.top);
      }

      writeln("");

      immutable modes = DisplayManager.fullScreenDisplayModes;

      writefln("Number of display modes: %s", modes.length);

      foreach (i, mode; modes)
      {
         writefln("   Mode %s: %sx%s pixels @ %s Hz, pixel format: %s", i,
                  mode.width, mode.height, mode.refresh_rate, mode.format);
      }

      // We're done!
      return 0;
   });
}
