/**
 * An example showing the joysticks detected by $(D InputManager).
 *
 * Authors: Leandro Motta Barros
 */

import std.array;
import std.stdio;
import std.string;
import fewdee.all;



void main()
{
   al_run_allegro(
   {
      // Start the engine.
      scope crank = new fewdee.engine.Crank();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Load a font. We are not using the 'ResourceManager', so we'll have to
      // free it manually latter.
      enum fontSize = 20;
      enum fontSpacing = fontSize * 1.3;
      Font font = new Font("data/bluehigl.ttf", fontSize);

      // Helper function, to draw text on the screen
      void drawText(string text, float x, float y)
      {
         al_draw_text(font, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                      text.toStringz);
      }

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // Allegro sends an ALLEGRO_EVENT_JOYSTICK_CONFIGURATION event when it
      // detects that joysticks are connected or disconnected. In response to
      // this event, we call InputManager.rescanJoysticks(), which will rescan
      // the system for joysticks and update the internal data structures that
      // contain the joystick information.
      EventManager.addHandler(
         ALLEGRO_EVENT_JOYSTICK_CONFIGURATION,
         delegate(in ref ALLEGRO_EVENT event)
         {
            writeln("Joystick connected or disconnected!");
            InputManager.rescanJoysticks();
         });

      // Draw! Reads joystick information in InputManager.joysticks and displays
      // it on the window.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(50, 50, 50));

            drawText("InputManager joysticks example (ESC to quit)",
                     15, fontSize);

            auto y = 15 + fontSpacing;

            foreach (joy; InputManager.joysticks)
            {
               // Joystick name
               drawText("Joystick: '" ~ joy.name ~ "'", 15, y);
               y += fontSpacing;

               // Joystick buttons
               drawText("Buttons: " ~ join(joy.buttons.dup, ", "), 30, y);
               y += fontSpacing;

               // Joystick axes
               drawText("Axes: " ~ join(joy.axes.dup, ", "), 30, y);
               y += fontSpacing;
            }
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // Free resources
      font.free();

      // We're done!
      return 0;
   });
}
