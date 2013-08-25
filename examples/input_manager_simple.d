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


// The Input Manager provides abstracted input. By abstracted, I mean that it
// allows you to write your game close to the game domain, not at the input
// devices domain. You don't deal with low-level events, like key presses and
// joysticks sticks moving. Instead, you work with commands like "jump" and
// "fire" and with states like "walking direction" and "thrust".
//
// So, the Input Manager deals with kinds of input: commands and
// states. Commands work like events: when a command is triggered, its command
// handlers are called. States are values that get automatically updated as user
// input is handled; you then query the value of the states whenever needed.


// First thing is to create enumerations with the high-level commands you want
// to handle.
private enum TheCommands
{
   JUMP,
   FIRE,
}

// And the same with states. Here, we have just one state, that will represent a
// "walking direction".
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

      // Prior to using the InputManager, we have to tell it which constants
      // we'll be using for commands and states. We do this by calling
      // initInputConstants(). (If you are using only commands, or only states,
      // you can call initInputCommandsConstants() or initInputStatesConstants()
      // instead.)
      initInputConstants!(TheCommands, TheStates)();

      // Now, let's configure the InputManager so that it knows when to trigger
      // commands. For the first time, we'll deal with 'InputTrigger's.
      //
      // An 'InputTrigger' is an object that receives low-level events,
      // processes them, and "triggers" when one of these low-level events do
      // what it is looking for. Simple 'InputTrigger's trigger in reaction to a
      // single low-level event (a key press, for instance). More complex
      // 'InputTrigger's could trigger, for example, when a key is kept pressed
      // for a certain amount of time, or when the Konami Code is entered.
      //
      // Lets start telling the Input Manager that we want to trigger a "jump"
      // command whenever the space key is pressed. For this, we'll use a
      // 'KeyDownTrigger':
      InputManager.addCommandTrigger(
         TheCommands.JUMP, new KeyDownTrigger(ALLEGRO_KEY_SPACE));

      // Similarly, trigger a "fire" command when the alt key is pressed.
      InputManager.addCommandTrigger(
         TheCommands.FIRE, new KeyDownTrigger(ALLEGRO_KEY_ALT));

      // You can associate as many triggers you want to a given command. Let's
      // tell the Input Manager to trigger jump and fire commands when,
      // respectively, buttons 0 and 1 of the joystick 0 are pressed.
      InputManager.addCommandTrigger(
         TheCommands.JUMP, new JoyButtonDownTrigger(0, 0));
      InputManager.addCommandTrigger(
         TheCommands.FIRE, new JoyButtonDownTrigger(0, 1));

      // And, just 'cause we can, do same for he second joystick.
      InputManager.addCommandTrigger(
         TheCommands.JUMP, new JoyButtonDownTrigger(1, 0));
      InputManager.addCommandTrigger(
         TheCommands.FIRE, new JoyButtonDownTrigger(1, 1));

      // Up to this point, we just configured the Input Manager, telling what
      // triggers the high-level commands. We still didn't tell it what we want
      // to do when these commands are triggered. That's what we'll do next,
      // calling InputManager.addCommandHandler().
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

      // We are finished with commands. Time to deal with our only input state.
      // We'll use a 'DirectionInputState', which provides an eight-way
      // directional state. We instantiate it, and add it to the Input Manager:
      auto dirState = new DirectionInputState();
      InputManager.addState(TheStates.WALK_DIR, dirState);

      // Once more, we meet the 'InputTrigger's. An 'InputState' knows how to
      // update its internal state, but it doesn't know what shall trigger these
      // updates. So, we have to setup the 'InputState', telling which
      // 'InputTrigger's we want to use.
      //
      // In the case of a 'DirectionInputState', we would have to manually set
      // eight triggers (four directions, one trigger to start and one to stop
      // moving to that direction). We could actually do this, but
      // 'DirectionInputState' provides shortcuts for the common cases of using
      // key presses and joystick axes to control the direction.
      //
      // Let's start telling 'dirState' to use key up and key down events. The
      // useKeyTriggers() method accepts as parameters the scan codes
      // (ALLEGRO_KEY_*) constants of the keys to associate with each
      // direction. By default, it will use the keyboard arrow keys, which is
      // what we normally want anyway:
      dirState.useKeyTriggers();

      // In addition to the arrow keys, let's make the direction controllable by
      // the first joystick (joystick 0). By default, useJoyAxesTriggers() will
      // use the first axis as the horizontal direction and the second axis as
      // the vertical direction. For most joysticks, this shall be just what is
      // needed.
      dirState.useJoyAxesTriggers(0);

      // And that's it, from this point on, the direction state will be updated
      // as the user generates keyboard and joystick events.

      // Now, let's make our life easier. Reading the state value is a bit
      // verbose, as it involves a downcast from the base 'InputState' class to
      // the concrete state class we are using. So, in order to make our code
      // cleaner, let's encapsulate this in something handier to use.
      @property StateDir TheDirection()
      {
         return
            (cast(DirectionInputState)(InputManager.state(TheStates.WALK_DIR)))
            .direction;
      }

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // Draw. In addition to some generic messages, we print the current
      // walking direction to the screen.
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
