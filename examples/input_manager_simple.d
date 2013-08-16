/**
 * A simple example showing how to use the $(D InputManager).
 *
 * Authors: Leandro Motta Barros
 */

import std.conv;
import std.exception;
import std.stdio;
import std.string;
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

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
private enum TheStates
{
   WALK_DIR,
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

      // Helper function, to draw text on the screen
      void drawText(string text, float x, float y)
      {
         al_draw_text(font, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                      text.toStringz);
      }

      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      initInputConstants!(TheCommands, TheStates)();

      InputManager.addCommandTrigger(TheCommands.JUMP, new KeyDownTrigger(ALLEGRO_KEY_SPACE));
      InputManager.addCommandTrigger(TheCommands.FIRE, new KeyDownTrigger(ALLEGRO_KEY_ALT));

      InputManager.addCommandTrigger(TheCommands.JUMP, new JoyButtonDownTrigger(0));
      InputManager.addCommandTrigger(TheCommands.FIRE, new JoyButtonDownTrigger(1));

      InputManager.addCommandHandler(
         TheCommands.JUMP,
         delegate(in ref InputHandlerParam param)
         {
            writefln("JUMP! (%s)", param.source);
         });

      InputManager.addCommandHandler(
         TheCommands.FIRE,
         delegate(in ref InputHandlerParam param)
         {
            writefln("FIRE! (%s)", param.source);
         });


      // State

      auto dirState = new DirectionInputState();
      InputManager.addState(TheStates.WALK_DIR, dirState);

      @property DirectionInputState.Direction TheDirection()
      {
         return
            (cast(DirectionInputState)(InputManager.state(TheStates.WALK_DIR)))
            .direction;
      }

      dirState.addStartNorthTrigger(new KeyDownTrigger(ALLEGRO_KEY_UP));
      dirState.addStartNorthTrigger(new JoyAxisDecreaseTrigger(0, 1, -0.5));

      dirState.addStopNorthTrigger(new KeyUpTrigger(ALLEGRO_KEY_UP));
      dirState.addStopNorthTrigger(new JoyAxisIncreaseTrigger(0, 1, -0.5));

      dirState.addStartSouthTrigger(new KeyDownTrigger(ALLEGRO_KEY_DOWN));
      dirState.addStartSouthTrigger(new JoyAxisIncreaseTrigger(0, 1, 0.5));

      dirState.addStopSouthTrigger(new KeyUpTrigger(ALLEGRO_KEY_DOWN));
      dirState.addStopSouthTrigger(new JoyAxisDecreaseTrigger(0, 1, 0.5));

      dirState.addStartEastTrigger(new KeyDownTrigger(ALLEGRO_KEY_RIGHT));
      dirState.addStartEastTrigger(new JoyAxisIncreaseTrigger(0, 0, 0.5));

      dirState.addStopEastTrigger(new KeyUpTrigger(ALLEGRO_KEY_RIGHT));
      dirState.addStopEastTrigger(new JoyAxisDecreaseTrigger(0, 0, 0.5));

      dirState.addStartWestTrigger(new KeyDownTrigger(ALLEGRO_KEY_LEFT));
      dirState.addStartWestTrigger(new JoyAxisDecreaseTrigger(0, 0, -0.5));

      dirState.addStopWestTrigger(new KeyUpTrigger(ALLEGRO_KEY_LEFT));
      dirState.addStopWestTrigger(new JoyAxisIncreaseTrigger(0, 0, -0.5));

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
            drawText("InputManager simple example", 30, 30);
            drawText("Generate some events and watch the console", 50, 60);
            drawText("Press ESC to quit", 50, 90);

            drawText("Direction: " ~ to!string(TheDirection), 50, 150);
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
