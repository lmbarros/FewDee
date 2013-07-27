/**
 * FewDee's Inout Manager and related definitions.
 *
 * The Input Manager provides means to handle input in a more abstract fashion:
 * instead of responding to low-level events like "key down" or "joystick button
 * up", you can respond to high-level fame events like "jump" or "use
 * nitro". The mapping between low-level and high-level events is flexible, so
 * that you can easily support multiple input devices or even allow
 * user-customization of the input.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_manager;

import std.conv;
import std.traits;
// import std.exception;
// import allegro5.allegro;
// import fewdee.engine;
// import fewdee.event_manager;
import fewdee.internal.singleton;



class CommandTrigger
{
   public abstract string encode();

   // decodes from (part of) a string. returns the remaining string.
   public abstract char[] decode(char[]);
}

class DummyCommandTrigger: CommandTrigger
{
   public override string encode() { return "{}"; }

   public override char[] decode(char[] data) { return data; }
}


class GameInputState
{
}


class DummyGameInputState: GameInputState
{
}


// associate command enum values to strings; necessary for the memento-style
// features (mappings as strings).
// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx better name; something sounding more global
void setupMappingConstants(Enum)()
   if (is(Enum == enum))
{
   InputManager.clearCommandMappings();
   foreach (member; EnumMembers!Enum)
      InputManager.addCommandMapping(to!string(member), member);
}



/**
 * The real implementation of the Input Manager. Users shall use this through
 * the $(D InputManager) class.
 */
private class InputManagerImpl
{
   // returns base GameInputState...and the user downcasts... possibly
   // encapsulating this in some global function/property.
   public final @property const(GameInputState) state(int command) const
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return new GameInputState();
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // xxxxxxxxxxxxx Idea: as this (and addState()) is called, add to internal
   // structures the "prototypes" that will be used to read mappings from a
   // string. Problem: this requires a 'CommandTrigger' as parameter, which is
   // exactly what we want to hide/abstract away...
   public final void addCommand(int command, CommandTrigger trigger)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   public final void addState(int command, GameInputState state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // To avoid triggering certain commands
   public final void enableCommands(int[] commands...)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // To restart triggering certain commands
   public final void disableCommands(int[] commands...)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }


   // mappings between command enum names and enum values
   private final void clearCommandMappings()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // mappings between command enum names and enum values
   private final void addCommandMapping(in string name, int value)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // Memento! Maybe a better name; 'state' is limited to mappings or so...
   public final @property string state() inout
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return "";
   }

   /// Ditto.
   public final @property void state(in string state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

}



/**
 * The Input Manager singleton. Provides access to the one and only $(D
 * InputManagerImpl) instance.
 */
public class InputManager
{
   mixin LowLockSingleton!InputManagerImpl;
}




/+++++++++++++++++++++++++++++++++++++++++

// // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// enum MyCmds ...;
// AbstractedInput!MyCmds absInput;

// absInput.addMapping(filter, MyCmds.JUMP);

// absInput.addState();




//  - "Configure commands" screen.
//  - Select keyboard/joystick/whatever
//  - 

class Foo
{
   bool boolState(string key) const { return true; }
}

// subclass only if wants states?
class MyAbsInp: AbstractedInput
{
   // name, type, default value
   mixin(addBoolState("turbo", TRANSIENT, false));
   mixin(addBoolState("landingGears", TOGGLE, true)); // support one key to turn on, one to turn off?
   mixin(addBoolState("canopyOpen", TOGGLE, false)); // delayed? after issuing command, takes some time to change state.

   mixin(addFloatState!double("thrust", 0.5, 0.0, 1.0)); // default value, min, max (auto-clipped, default is -float.max, float.max)
   mixin(addDir8State("walkingDirection")); // NONE, N, NE, E, SE, S, SW, W, NW
}


auto mai = new MyAbsInp();

id = mai.link(trigger, CMD_JUMP); // -> EventManager.postEvent(FEWDEE_EVENT_INPUT_EVENT); // or something like this


id = mai.link!"turbo"(triggerKeyT);
id = mai.link!"landingGears"(triggerKeyG);
id = mai.link!"landingGears"(triggerKeyG, triggerKeyH); // different keys for true and false ---> well... there are always two commands. Like keyXDown turns true, keyXUp turns false
id = mai.link!"thrust"(joyAxis(joy1, axis0));
id = mai.link!"thrust"(key+, key-); // one key increments, other decrements
id = mai.link!"thrust"(key+, key-);


mai.unlink(id);

if (mai.turbo)
   vrumVrum();

++++++++++++++++++++++++++++++++++/
