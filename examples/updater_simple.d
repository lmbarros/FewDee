/**
 * FewDee's "Simple Updater" example. Shows the simplest possible usage of an
 * $(D Updater) (in fact, of a $(D TickBasedUpdater), which is probably what
 * most people will want to use in practice).
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.stdio;
import std.string;
import fewdee.all;


void main()
{
   al_run_allegro(
   {
      // Start the engine.
      scope crank = new fewdee.engine.Crank();

      // Create the updater. We are using a 'TickBasedUpdater' here, which is a
      // handy subclass of 'Updater'. The 'Updater' class itself only calls the
      // registered updater functions when its 'update()' method is called. The
      // 'TickBasedUpdater' registers itself with the 'EventManager' so that it
      // can run the updater functions as it gets "tick" events
      // (FEWDEE_EVENT_TICK). You can think of 'TickBasedUpdater' as an
      // automated 'Updater'.
      scope updater = new TickBasedUpdater();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Load a font. We are not using the 'ResourceManager', so we'll have to
      // free it manually latter.
      Font font = new Font("data/lato.otf", 22);

      // Lil' function to draw text on the display
      void drawText(string text, float x, float y)
      {
         al_draw_text(
            font, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
            text.toStringz);
      }

      // Register event handlers

      // Start an updater when the mouse is clicked. Notice that many instances
      // of the updater function will run simultaneously if the user clicks
      // several times in sequence.
      EventManager.addHandler(
         ALLEGRO_EVENT_MOUSE_BUTTON_UP,
         delegate(in ref ALLEGRO_EVENT event)
         {
            // Here we create a closure and add it to the Updater. This will run
            // for one and a half second.
            auto totalTime = 0.0;
            immutable id = updater.add(
               delegate(double deltaTime)
               {
                  totalTime += deltaTime;
                  writefln("%s: Updater called (%s seconds)",
                           &totalTime, totalTime);

                  // When an updater function returns 'true', it means "please
                  // keep calling me"; when it returns 'false', it is actually
                  // saying "I'm done, don't call me anymore."
                  return totalTime < 1.5;
               });

            // Print the ID of the updater function added. This value can be
            // passed to the updater's 'remove()' method, if you want to remove
            // an updater before it considers itself done.
            writefln("Added updater %s", id);
         });

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // Just draw some instructions. All interesting output goes to the
      // console, as the updaters are called.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(50, 50, 50));
            drawText("Updater simple example", 30, 30);
            drawText("Click to start updater (and watch your console!)",
                     50, 60);
            drawText("Press ESC to quit", 50, 90);
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
