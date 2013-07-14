/**
 * A simple example showing the use of $(D AbstractedInput).
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.stdio;
import fewdee.all;


// These are the high-level commands that will be used in this
// example. 'NOTHING' is there just for testing purposes; in real usage, you'll
// create an enum only with real high-level commands.
private enum TheCommands
{
   JUMP,
   FIRE,
   NOTHING,
}



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
      Font font = new Font("data/bluehigl.ttf", 30);

      // Helper function, to draw on the screen
      void drawText(string text, float x, float y)
      {
         al_draw_text(font, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                      text.ptr);
      }

      // Create the 'AbstractedInput'. It is created without mappings between
      // low-level events and high-level commands, nor with any high-level event
      // handlers. Adding those is our next step.
      auto abstractedInput = new AbstractedInput!TheCommands();

      // Here we create the first mapping between low-level events and
      // high-level commands. In this case, we are saying that when the space
      // bar is pressed, then a 'JUMP' command must be triggered.
      abstractedInput.addMapping(keyPress(ALLEGRO_KEY_SPACE), TheCommands.JUMP);

      // Like above: pressing "alt" triggers a 'FIRE' command.
      abstractedInput.addMapping(keyPress(ALLEGRO_KEY_ALT), TheCommands.FIRE);

      // Add some more mappings. Notice that we are adding alternative mappings
      // for the same commands. Specifically, pressing joystick buttons will
      // cause 'JUMP' and 'FIRE' high-level commands.
      abstractedInput.addMapping(joyButtonPress(0), TheCommands.JUMP);
      abstractedInput.addMapping(joyButtonPress(1), TheCommands.FIRE);

      // Up to this point, we just told the 'AbstractedInput' how to generate
      // the high-level commands we want to handle from the low-level events
      // that Allegro generates. We still have to tell 'AbstractedInput' what we
      // want done when high-level commands are triggered. That's what we'll do
      // next.
      abstractedInput.addHandler(
         TheCommands.JUMP,
         delegate(in ref HighLevelCommandHandlerParam param)
         {
            writeln("JUMP!", param.sourceIsKeyboard ? " (keyboard)" : "");
         });

      abstractedInput.addHandler(
         TheCommands.FIRE,
         delegate(in ref HighLevelCommandHandlerParam param)
         {
            writeln("FIRE!", param.sourceIsKeyboard ? " (keyboard)" : "");
         });

      // This is just to ensure that we can add a callback for which there is no
      // associated mapping.
      abstractedInput.addHandler(
         TheCommands.NOTHING,
         delegate(in ref HighLevelCommandHandlerParam param)
         {
            writeln("NOTHING!");
         });

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(50, 50, 50));
            drawText("AbstractedInput simple example", 30, 30);
            drawText("Generate some events and watch the console", 50, 60);
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
