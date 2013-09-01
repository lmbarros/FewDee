/**
 * An example showing how to use the $(D InputListener) to allow the user to
 * configure the input and the memento-like interface to persist the input
 * configuration.
 *
 * Authors: Leandro Motta Barros
 */

import std.file;
import std.stdio;
import fewdee.all;


// We'll have two high-level commands. Here's the 'enum' listing them.
private enum TheCommands
{
   JUMP,
   FIRE,
}

// The 'InputManager' configuration will be stored in a file with this name.
enum configFile = "input_listener_memento.cfg";


// This font is the only resource used in this example. In real programs, you'll
// probably want to use the 'ResourceManager', but here we'll do all resource
// management manually.
private Font theFont;

// We'll want to draw some text, so here is something that will help us. Again,
// we are avoiding to use higher level abstractions provided by FewDee, in order
// to focus on what this example is supposed to be about. Anyway, notice how the
// FewDee wrappers (like Font) work seamlessly with the Allegro API.
private void drawText(string text, float x, float y)
in
{
   assert(theFont !is null);
}
body
{
   al_draw_text(
      theFont, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT, text.ptr);
}


void main()
{
   al_run_allegro(
   {
      // Start the engine.
      scope crank = new fewdee.engine.Crank();

      // Load a font. We are not using the 'ResourceManager', so we'll have to
      // free it manually latter.
      theFont = new Font("data/bluehigl.ttf", 30);

      // Tell the 'InputManager' which are the commands we'll be using. Since we
      // are not using any 'InputStates', we can't use
      // 'initInputConstants()'. No problem: 'initInputCommandsConstants()'
      // exists for this case.
      initInputCommandsConstants!(TheCommands)();

      // Once the 'InputManager' knows what are the commands it will deal with,
      // we can load its configuration from a file. That's what we do
      // next. However, if the configuration file doesn't exist or if some error
      // happens while loading it, we use a default configuration.
      try
      {
         // Read the configuration from the configuration file as a string.
         const strConfig = readText(configFile);

         // Parse the configuration string to a 'ConfigValue'.
         const ConfigValue configData = parseConfig(strConfig);

         // To restore the 'InputManager' configuration, we just assign the
         // 'ConfigValue' we just obtained to 'InputManager.memento'.
         InputManager.memento = configData;

         writefln("Using configuration from '%s'.", configFile);
      }
      catch (Exception e)
      {
         writeln(e.msg);
         writefln("Falling back to default configuration.");

         // Just add triggers to the commands normally.
         InputManager.addCommandTrigger(
            TheCommands.JUMP, new KeyDownTrigger(ALLEGRO_KEY_SPACE));
         InputManager.addCommandTrigger(
            TheCommands.FIRE, new KeyDownTrigger(ALLEGRO_KEY_ALT));
      }

      // Either way, thhe 'InputManager' is configured at this point. Let's add
      // some handlers for our commands.
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

      // Create a display
      DisplayManager.createDisplay("main");

      // Starts the game main loop, with an 'MainGameState' as the starting
      // state. The loop will run as long as there is at least one state in the
      // stack of states maintained by the 'StateManager'.
      run(new MainGameState());

      // Free resources
      theFont.free();

      // We're done!
      return 0;
   });
}


// This is the state in which the example starts. It is where input events are
// handled.
private class MainGameState: GameState
{
   // In the constructor, we register the event handlers we need.
   public this()
   {
      // Exit when ESC is pressed. Enter the 'ConfigInputState' when F10 is
      // pressed.
      //
      // TODO: Notice using ALLEGRO_EVENT_KEY_DOWN here should work, but it
      //       doesn't (because the 'InputListener' in the 'ConfigInputState'
      //       will also listen to that key down event and assume that the user
      //       wants to use it). This is a known bug, with an idea of solution
      //       documented in the 'dev_notes/TODO.org' file.
      addHandler(
         ALLEGRO_EVENT_KEY_UP,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               popState();
            else if (event.keyboard.keycode == ALLEGRO_KEY_F10)
               pushState(new ConfigInputState());
         });

      // Handle drawing. Just use a blueish background color and print some
      // informative text.
      addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(10, 10, 50));
            drawText("Initial State", 30, 30);
            drawText("Generate some events and watch the console", 50, 60);
            drawText("Press F10 to configure input; ESC to quit", 50, 90);
         });

   }

   // The 'InputManager' works globally, but don't want "jump" and "fire" events
   // when we are not in this initial state. It doesn't make sense to jump and
   // fire while in the 'ConfigInputState', right? So, we have to disable these
   // events whenever some other state is pushed on top of this one in the stack
   // of states, and re-enable them when this state becomes the top one
   // again. The 'onBury()' and 'onDigOut()' methods of 'GameState' exist for
   // cases like this. Just notice that we call the 'super' version of the
   // method, because we want to keep the default behavior of not receiving
   // events while buried under another state.
   public override void onBury()
   {
      super.onBury();
      InputManager.disableCommands(TheCommands.FIRE, TheCommands.JUMP);
   }

   public override void onDigOut()
   {
      super.onDigOut();
      InputManager.enableCommands(TheCommands.FIRE, TheCommands.JUMP);
   }
};


// This is the state used to configure the input.
private class ConfigInputState: GameState
{
   // We'll configure two different commands, so we'll need to know which
   // command we are currently configuring. This is the purpose of this
   // variable.
   private TheCommands _currentCommand = TheCommands.JUMP;

   // To obtain user input in a way that is appropriate for configuring the
   // key bindings, we'll use an 'InputListener'.
   private InputListener _inputListener;

   // We'll need to store events listened by the 'InputListener'
   // somewhere. These two variables will be used for this.
   private ListenedEvent _listenedJumpEvent;
   private ListenedEvent _listenedFireEvent;

   // In the 'ConfigInputState' constructor we'll initialize the
   // 'InputListener', and add all the event handlers we'll need.
   public this()
   {
      // Instantiate the 'InputListener'
      _inputListener = new InputListener();

      // The "Escape" key will be used to cancel the input configuration. So, we
      // want the 'InputListener' to ignore this key. Likewise, we want to
      // ignore the F10 key, since it is hardcoded to mean "show me the input
      // configuration screen".
      _inputListener.setIgnoredKeys(ALLEGRO_KEY_ESCAPE, ALLEGRO_KEY_F10);

      // For the first event we are listening to, let's say that only keyboard
      // events are allowed
      _inputListener.validInputSources = InputSource.KEYBOARD;

      // The 'InputListener' is created in a "not listening" state. We gotta
      // make it listen.
      _inputListener.startListening();

      // As we said above, pressing the "Escape" key will mean "get me out of
      // the input configuration screen without changing the key bindings". So,
      // when "Escape" is pressed, we simply pop this state from the stack of
      // Game States; this will take us back to the initial state without making
      // any change in the key assignments.
      //
      // TODO: As consequence of having to use the "key up" event in the other
      //       Game State (see the TODO above), we have to use the key up event
      //       here, too.
      addHandler(
         ALLEGRO_EVENT_KEY_UP,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               popState();
         });

      // Handle drawing. Just use a reddish background color and print some
      // informative text.
      addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            auto msg = (_currentCommand == TheCommands.JUMP)
               ? "Enter key for jumping."
               : "Enter key for firing.";

            al_clear_to_color(al_map_rgb(50, 10, 10));
            drawText("Configuring Input", 30, 30);
            drawText(msg, 50, 60);
            drawText("Press ESC to cancel input configuration", 50, 90);
         });

      // The "tick" event handler is where most of the magic happens. It is here
      // that we'll check if the 'InputListener' has listened to the event. And,
      // if it did, it is here that we'll read the listened event data and use
      // it.
      addHandler(
         FEWDEE_EVENT_TICK,
         delegate(in ref ALLEGRO_EVENT event)
         {
            // If the 'InputListener' hasn't listened to an event yet, we leave
            // immediately.
            if (!_inputListener.hasListened)
               return;

            if (_currentCommand == TheCommands.JUMP)
            {
               // The 'InputListener' listened to an event and we were currently
               // waiting for the "jump" event. First, we save the event data,
               // since we'll use it later to reconfigure the input
               // configuration. (BTW, we don't update the input configuration
               // right here just because we still want to allow user to press
               // "Escape" to cancel the configuration process.)
               _listenedJumpEvent = _inputListener.listenedEvent;

               // We don't want to allow the user to set the same key as both
               // "jump" and "fire", so we add the "jump" key we just read to
               // the list of keys to ignore.
               //
               // TODO: This currently only works for keyboard keys; joystick
               //       buttons should be ignorable, too.
               if (_listenedJumpEvent.source == InputSource.KEYBOARD)
                  _inputListener.addIgnoredKeys(_listenedJumpEvent.code);

               // We are done with the "jump" event. Say that we are now
               // listening to the event for "fire".
               _currentCommand = TheCommands.FIRE;

               // For "fire" events, we'll accept both the keyboard and first
               // joystick.
               _inputListener.validInputSources =
                  InputSource.KEYBOARD | InputSource.JOY0;

               // Restart listening to events.
               _inputListener.startListening();
            }
            else
            {
               // Reaching this point means that we just got the second event we
               // wanted: the one that will trigger "fire" commands.
               assert(_currentCommand == TheCommands.FIRE);

               // Again, we save the listened command data. (Since we'll use
               // this data right here, we could use
               // '_inputListener.listenedEvent' directly instead. The way we
               // are doing here is a bit more consistent: having two
               // similarly-named variables for two similar things will
               // hopefully make the code easier to follow).
               _listenedFireEvent = _inputListener.listenedEvent;

               // The events we just listened to will replace the current "key
               // bindings", so we just clear the current ones. In real life,
               // you could be more specific, and just remove some of the
               // commands triggers (see 'InputManager.removeCommandTrigger()').
               InputManager.clearCommandTriggersAndStates();

               // Now, recreate the command triggers, but using the data from
               // the use the listened events.
               InputManager.addCommandTrigger(
                  TheCommands.JUMP,
                  new KeyDownTrigger(_listenedJumpEvent.code));

               if (_listenedFireEvent.source == InputSource.KEYBOARD)
               {
                  InputManager.addCommandTrigger(
                     TheCommands.FIRE,
                     new KeyDownTrigger(_listenedFireEvent.code));
               }
               else if (_listenedFireEvent.source == InputSource.JOY0)
               {
                  InputManager.addCommandTrigger(
                     TheCommands.FIRE,
                     new JoyButtonDownTrigger(0, _listenedFireEvent.code));
               }

               // Now, we use the memento-style interface of 'InputManager' to
               // save this updated configuration to a file. Next time this
               // example starts, the configuration will be read from there.
               try
               {
                  // By default, 'stringify()' produces "pretty printed"
                  // strings, with indentation and spacing that make them easier
                  // to read by human beings. If you want to spare these extra
                  // bytes of blanks, just pass an option 'false' parameter to
                  // 'stringify()'.
                  string strConfig = InputManager.memento.stringify();

                  // Dump the data to the configuration file.
                  std.file.write(configFile, strConfig);

                  writefln("Input configuration saved to '%s'", configFile);
               }
               catch (Exception e)
               {
                  writeln(e.msg);
                  writeln("Error saving new input configuration.");
               }

               // And that's it. We can now leave the 'ConfigInputState', as we
               // did everything we had to do.
               popState();
            }
         });
   }

   // The 'StateManager' guarantees that Game States are destroyed as soon as
   // they are removed from the stack of states. So, we can use the State
   // destructor do explicitly destroy the 'InputListener'. Not destroying it
   // would cause it to keep listening to events, wasting memory and CPU
   // cycles. One way or another, always destroy your 'InputListener's when they
   // are no longer needed.
   public ~this()
   {
      destroy(_inputListener);
   }
};


