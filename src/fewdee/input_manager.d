/**
 * FewDee's Input Manager and related definitions.
 *
 * The Input Manager provides means to handle input in a more abstract fashion:
 * instead of responding to low-level events like "key down" or "joystick button
 * up", you can respond to high-level fame events like "jump" or "use
 * nitro". The mapping between low-level and high-level events is flexible, so
 * that you can easily support multiple input devices or even allow
 * user-customization of the input.
 *
 * This module may feel over-engineered: using it involves so many classes that
 * it fells like Java. In fact, I started with a considerably simpler design,
 * which failed miserably when I tried to use it in a little game prototype I
 * developed with an early version of FewDee. Wondering about this failure, I
 * made a list of what I considered essential for the kind of effective
 * abstracted input mechanism I wanted to use. This design is the simplest one I
 * could devise that respected all my requisites. Anyway, if you think it is $(I
 * too) convoluted, you don't have to use it at all -- its usage is completely
 * optional.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_manager;

import std.conv;
import std.exception;
import std.traits;
import std.typecons;
import allegro5.allegro;
import fewdee.config;
import fewdee.engine;
import fewdee.input_helpers;
import fewdee.low_level_event_handler;
import fewdee.internal.collections;
import fewdee.internal.singleton;


/**
 * The possible sources of input.
 *
 * Notice that these values can be used in bitfields. This could be used to
 * indicate that a certain high-level input event was generated as a combination
 * of multiple input devices. For example, maybe your game does something
 * special when the player moves the mouse cursor while pressing shift; this
 * "something special" event would have both the mouse and the keyboard bits
 * set. (If this would be a good interface, that's another story...)
 */
public enum InputSource
{
   INVALID = 0,        /// An invalid input source.
   GUI = 1 << 1,       /// The event was generated via GUI widgets
   KEYBOARD = 1 << 2,  /// The keyboard.
   MOUSE = 1 << 3,     /// The mouse.
   JOY0 = 1 << 4,      /// The first joystick.
   JOY1 = 1 << 5,      /// The second joystick.
   JOY2 = 1 << 6,      /// The third joystick.
   JOY3 = 1 << 7,      /// The fourth joystick.
   JOY4 = 1 << 8,      /// The fifth joystick.
   JOY5 = 1 << 9,      /// The sixth joystick.
   JOY6 = 1 << 10,     /// The seventh joystick.
   JOY7 = 1 << 11,     /// The eight joystick.
   JOY8 = 1 << 12,     /// The ninth joystick.
   JOY9 = 1 << 13,     /// The tenth joystick.
}



/**
 * A generic structure passed as parameter to input handlers.
 *
 * Please note that this structure has only private members. To access the
 * struct's data, please use the functions designed to extract information from
 * it. (Check the "See also" section.)
 *
 * See_also: source, isSourceGUI, isSourceKeyboard, isSourceMouse,
 *    isSourceJoy0
 */
public struct InputHandlerParam
{
   /// The event source.
   private InputSource _source;
}

/**
 * The event source.
 *
 * Technically, the event source is a bitfield, but in most practical cases only
 * one bit will be set.
 */
public @property InputSource source(const InputHandlerParam p)
{
   return p._source;
}

/// Ditto.
public @property void source(ref InputHandlerParam p, InputSource source)
{
   p._source = source;
}

/// Checks if the input source is a certain one.
public bool isSourceGUI(const InputHandlerParam p)
{
   return p._source == InputSource.GUI;
}

/// Ditto.
public bool isSourceKeyboard(const InputHandlerParam p)
{
   return p._source == InputSource.KEYBOARD;
}

/// Ditto.
public bool isSourceMouse(const InputHandlerParam p)
{
   return p._source == InputSource.MOUSE;
}

/// Ditto.
public bool isSourceJoy0(const InputHandlerParam p)
{
   return p._source == InputSource.JOY0;
}

/// Ditto.
public bool isSourceJoy1(const InputHandlerParam p)
{
   return p._source == InputSource.JOY1;
}

/// Ditto.
public bool isSourceJoy2(const InputHandlerParam p)
{
   return p._source == InputSource.JOY2;
}

/// Ditto.
public bool isSourceJoy3(const InputHandlerParam p)
{
   return p._source == InputSource.JOY3;
}

/// Ditto.
public bool isSourceJoy4(const InputHandlerParam p)
{
   return p._source == InputSource.JOY4;
}

/// Ditto.
public bool isSourceJoy5(const InputHandlerParam p)
{
   return p._source == InputSource.JOY5;
}

/// Ditto.
public bool isSourceJoy6(const InputHandlerParam p)
{
   return p._source == InputSource.JOY6;
}

/// Ditto.
public bool isSourceJoy7(const InputHandlerParam p)
{
   return p._source == InputSource.JOY7;
}

/// Ditto.
public bool isSourceJoy8(const InputHandlerParam p)
{
   return p._source == InputSource.JOY8;
}

/// Ditto.
public bool isSourceJoy9(const InputHandlerParam p)
{
   return p._source == InputSource.JOY9;
}



/**
 * $(D InputTrigger)s form the first abstraction layer upon low-level input
 * events, allowing to treat, say, certain sequences of low-level events as
 * something that has a meaning as a whole.
 *
 * For certain needs (arguably, for most of them), low-level events could be
 * mapped directly to high-level game commands: when a certain low-level event
 * happens (a key or joystick button is pressed), a game command is executed (a
 * character jumps).
 *
 * Sometimes, however, you want to trigger a high-level command in response to
 * something that is more complex than a single low-level event. For example,
 * you may want to trigger a high-level game command in response to a sequence
 * of key presses ("enter god mode if the player presses I, D, K, F, A in
 * sequence" or "make this special fighting movement if the player presses a
 * given sequence of buttons"). Or perhaps you want to trigger a high-level
 * command for a "power up attack" after the player has maintained some button
 * pressed for a certain amount of time (in this case, the high-level game
 * command is triggered by a "release button" event, but only if its
 * corresponding "press button" event happened at least $(D n) seconds before).
 *
 * Here enter the $(D InputTrigger)s. They provide a unified interface to all
 * these diverse situations. Each $(D InputTrigger) subclass has its own way to
 * answer to a simple question: "Did this low-level event that just happened has
 * some special meaning for this game?" As said above, in some cases, pressing a
 * key has this "special meaning"; in other cases, the rules for "special
 * meaning" are more complex.
 */
class InputTrigger
{
   /**
    * Processes a low-level input event and tells if it triggered the $(D
    * InputTrigger).
    *
    * Parameters:
    *    event = The low-level event to process.
    *    param = If this method returns $(D true), whatever is written to this
    *       parameter will be passed to whoever handles the high-level event
    *       this $(D InputTrigger) is triggering. If this method returns $(D
    *       false), this value is ignored.
    *
    * Returns:
    *    If $(D event) did made the $(D InputTrigger) trigger, returns $(D
    *    true); otherwise returns $(D false).
    */
   public abstract bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param);

   /**
    * A representation of all the configuration of this $(D InputTrigger) (like
    * what key or joystick button is being "watched").
    *
    * This implements something akin to the Memento pattern. You can read this
    * property to obtain a somewhat opaque representation of the configuration
    * of this $(D InputTrigger) and write to it to restore a previous
    * configuration.
    */
   public abstract @property ConfigValue memento() inout;

   /// Ditto.
   public abstract @property void memento(const ConfigValue state);

   /**
    * Returns the class name of this class' class info.
    *
    * This is a string ready to be passed to $(D Object.factory()).
    */
   protected final @property string className() inout
   {
      return this.classinfo.name;
   }

   /// Initializes $(D _keyCodesStrings).
   private static this()
   {
      string genTableAssignments()
      {
         const keys = [
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "PAD_0", "PAD_1",
            "PAD_2", "PAD_3", "PAD_4", "PAD_5", "PAD_6", "PAD_7", "PAD_8",
            "PAD_9", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9",
            "F10", "F11", "F12", "ESCAPE", "TILDE", "MINUS", "EQUALS",
            "BACKSPACE", "TAB", "OPENBRACE", "CLOSEBRACE", "ENTER", "QUOTE",
            "BACKSLASH", "BACKSLASH2", "COMMA", "FULLSTOP", "SLASH", "SPACE",
            "INSERT", "DELETE", "HOME", "END", "PGUP", "PGDN", "LEFT", "RIGHT",
            "UP", "DOWN", "PAD_SLASH", "PAD_ASTERISK", "PAD_MINUS", "PAD_PLUS",
            "PAD_DELETE", "PAD_ENTER", "PRINTSCREEN", "PAUSE", "ABNT_C1",
            "KANA", "CONVERT", "NOCONVERT", "AT", "CIRCUMFLEX", "COLON2",
            "KANJI", "PAD_EQUALS", "BACKQUOTE", "SEMICOLON2", "COMMAND",
            "LSHIFT", "RSHIFT", "LCTRL", "RCTRL", "ALT", "ALTGR", "LWIN",
            "RWIN", "MENU", "SCROLLLOCK", "NUMLOCK", "CAPSLOCK" ];

         string code;
         foreach (key; keys)
         {
            code ~= "_keyCodesStrings[\"" ~ key ~ "\"] = ALLEGRO_KEY_"
               ~ key ~ ";\n";
         }

         return code;
      }

      mixin(genTableAssignments());
   }

   /**
    * Converts the string representation of a key code to the corresponding
    * Allegro key code.
    *
    * An Allegro key code $(D ALLEGRO_KEY_FOO) is equivalent to the string $(D
    * "FOO").
    *
    * Parameters:
    *    s = The string.
    *
    * Returns:
    *    The key code corresponding to $(D s); $(D ALLEGRO_KEY_MAX) if $(D s) is
    *    an invalid string (that is, a string that doesn't correspond to a key
    *    code).
    */
   protected static final int stringToKeyCode(string s)
   {
      auto p = s in _keyCodesStrings;
      if (p)
         return *p;
      else
         return ALLEGRO_KEY_MAX;
   }

   /**
    * Converts an Allegro key code to its string representation.
    *
    * An Allegro key code $(D ALLEGRO_KEY_FOO) is equivalent to the string $(D
    * "FOO").
    *
    * Parameters:
    *    c = The key code.
    *
    * Returns:
    *    The string version of $(D c); and empty string if $(D c) is an invalid
    *    key code.
    */
   protected static final string keyCodeToString(int c)
   {
      auto p = c in _keyCodesStrings;
      if (p)
         return *p;
      else
         return "";
   }

   /// Mappings between Allegro key codes and their string representations.
   private static BiMap!(string, int) _keyCodesStrings;
}

unittest
{
   // Valid strings
   assert(InputTrigger.stringToKeyCode("A") == ALLEGRO_KEY_A);
   assert(InputTrigger.stringToKeyCode("6") == ALLEGRO_KEY_6);
   assert(InputTrigger.stringToKeyCode("RIGHT") == ALLEGRO_KEY_RIGHT);
   assert(InputTrigger.stringToKeyCode("RCTRL") == ALLEGRO_KEY_RCTRL);

   // Valid key codes
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_U) == "U");
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_PAD_5) == "PAD_5");
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_UP) == "UP");
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_LSHIFT) == "LSHIFT");

   // Invalid strings
   assert(InputTrigger.stringToKeyCode("") == ALLEGRO_KEY_MAX);
   assert(InputTrigger.stringToKeyCode("MWHUAHUAHUA!") == ALLEGRO_KEY_MAX);

   // Invalid key codes
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_MAX) == "");
   assert(InputTrigger.keyCodeToString(ALLEGRO_KEY_MAX + 10) == "");
}



/**
 * An opaque identifier identifying an $(D InputTrigger) added to some other
 * data structure. It can be used to remove the trigger from there.
 */
public alias size_t TriggerID;


/**
 * A $(D TriggerID) that is guaranteed to be different to all real $(D
 * TriggerID)s. It is safe to pass this value to functions that remove triggers
 * from some structure: these functions will do nothing in this case.
 */
public immutable TriggerID InvalidTriggerID = 0;



/**
 * Base class for $(InputState)s, which store some information that changes as
 * input events are triggered.
 *
 * $(InputState)s can be used, for example, to easily have a "throttle" or a
 * "walking direction" value automatically updated in response to low-level
 * events.
 *
 * The low-level events triggering the changes in the state are not
 * hardcoded. Instead, they are based on $(D InputTrigger)s. This way, you can
 * configure which events will cause the state to change.
 *
 * For whoever wants to subclass $(D InputState), here are some instructions.
 *
 * Typically, a subclass will provide methods to add and remove triggers for
 * whatever situations are relevant for that kind of state. A state storing a
 * Boolean value, for instance, could have triggers for two situations: setting
 * the value to $(D true) and setting the value to $(D false). (An alternative
 * would be having a single set of triggers, that negate the current value.)
 *
 * Notice that the previous paragraph said "add and remove triggers" in the
 * plural. Indeed, unless there is some good reason to do differently, multiple
 * triggers should be supported for each of the "situations" that get
 * handled. This allows to assign multiple low-level events to the same
 * high-level purpose (for example, increase the throttle if the joystick
 * throttle axis is used, or if the "+" or "-" keys are pressed).
 *
 * In order to facilitate all this multiple triggers support, this base class
 * provides the means to manage collections of $(D InputTrigger)s indexed by
 * strings. Subclasses should leverage this to do their own work. (See $(D
 * addTrigger()) and $($D removeTrigger())).
 *
 * The $(D update()) method is supposed to, well, update the state. It is called
 * by the $(D StateManager) for each low-level event it receives. A typical
 * implementation will typically check if any of its $(D InputTrigger)s did
 * trigger, and, if so, update the state accordingly. The method $(D
 * didTrigger()) can be used to check if any of the triggers associated with a
 * given string did trigger.
 *
 * Finally, the $(D memento) property provides a way to save and restore the $(D
 * InputState) configuration. If you implement some kind of "configure input"
 * screen for your game, you'll want to allow the player to save the
 * configuration, right? These methods are the key to achieve this. They are
 * also used when you configure the whole input subsystem with a configuration
 * string.
 */
class InputState
{
   /**
    * A representation of all the configuration of this $(D InputState) (like
    * what its default value, which triggers are being used, and so on).
    *
    * Notice that the state itself is not stored in the memento. (By "state
    * itself" I mean the value or values that are automatically updated as the
    * user generates input events).
    *
    * This implements something akin to the Memento pattern. You can read this
    * property to obtain a somewhat opaque representation of the configuration
    * of this $(D InputState) and write to it to restore a previous
    * configuration.
    */
   public abstract @property ConfigValue memento() inout;

   /// Ditto.
   public abstract @property void memento(const ConfigValue state);

   /**
    * This gets called by the $(D InputManager) in order to update the $(D
    * InputState).
    */
   public abstract void update(in ref ALLEGRO_EVENT event);

   /**
    * Adds a trigger to one of the internal collections of triggers.
    *
    * Parameters:
    *    key = The key of the collection to which the trigger will be added.
    *    trigger = The trigger to add.
    *
    * Returns:
    *    An opaque ID that can be later passed to $(D removeTrigger()) if you
    *    want to remove $(D trigger).
    */
   public final TriggerID addTrigger(string key, InputTrigger trigger)
   {
      return _triggers.add(key, trigger);
   }

   /**
    * Removes a trigger from the internal collections of triggers.
    *
    * Parameters:
    *    triggerID = The ID of the trigger to remove. If there is no trigger
    *       with this ID, nothing happens. (Corollary: you can safely pass $(D
    *       InvalidTriggerID) here; nothing will happen in this case.)
    *
    * Returns:
    *    $(D true) if the trigger was removed; $(D false) if not (which means
    *    that no trigger with the given ID was found).
    */
   public final bool removeTrigger(TriggerID triggerID)
   {
      return _triggers.remove(triggerID);
   }

   /**
    * Removes a set of triggers from the internal collections of triggers.
    *
    * This is equivalent to calling $(removeTrigger()) for each ID sequentially.
    *
    * Parameters:
    *    triggerIDs = The IDs of the triggers to remove.
    */
   public final void removeTriggers(TriggerID[] triggerIDs)
   {
      foreach (id; triggerIDs)
         _triggers.remove(id);
   }

   /// Removes all triggers.
   public final void clearTriggers()
   {
      _triggers = typeof(_triggers).init;
   }

   /**
    * Checks if a given low-level event triggers any of the $(D InputTrigger)s
    * in one of the internal collection of triggers.
    *
    * In fact this method, does more than described above. Some $(D
    * InputTrigger)s may need to have their own $(D didTrigger()) method
    * continuously called in order to work properly. Calling this method does
    * just that.
    *
    * Parameters:
    *    key = The key of the collection of triggers that will be checked.
    *    event = The low-level event.
    *    param = The parameters returned by the trigger that triggered are
    *       retuned here. If multiple triggers trigger, the parameters of any of
    *       them are returned here. If no trigger has triggered, this will not
    *       have any meaningful information.
    *
    * Returns:
    *    $(D true) if any of the triggers in the collection with index $(D key)
    *    triggered.
    */
   public final bool didTrigger(string key, in ref ALLEGRO_EVENT event,
                                out InputHandlerParam param)
   {
      bool didIt = false;
      auto triggers = _triggers.get(key);
      foreach(id, trigger; triggers)
      {
         if (trigger.didTrigger(event, param))
            didIt = true;
      }

      return didIt;
   }

   /**
    * Returns the class name of this class' class info.
    *
    * This is a string ready to be passed to $(D Object.factory()).
    */
   protected final @property string className() inout
   {
      return this.classinfo.name;
   }

   /**
    * Encodes all the data concerning the input triggers associated with a given
    * key in a $(D ConfigValue), in the fashion expected by $(D memento).
    *
    * Parameters:
    *    key = The key of the desired triggers.
    *
    * Returns:
    *    The trigger data, ready to use by subclasses implementing the $(D
    *    memento) property.
    */
   protected final ConfigValue mementoizeTriggers(string key) inout
   {
      ConfigValue res;
      res.makeList();

      auto triggers = _triggers.get(key);
      foreach(trigger; triggers)
         res[res.length] = ConfigValue(trigger.memento);

      return res;
   }

   /// The collection of $(D InputTrigger)s.
   private
      BucketedCollection!(InputTrigger, string, TriggerID, InvalidTriggerID + 1)
         _triggers;
}



/**
 * Sets the $(InputManager) up so that it can properly work with the constants
 * describing the high-level input commands and the input states used in your
 * game.
 *
 * This must be called before using the $(InputManager). (Well, not really. This
 * is only really necessary if you want to use its "memento-like" features (see
 * the $(D memento) property). Anyway, calling this will not hurt, so do it
 * always anyway.)
 *
 * This function assumes that you are using both commands and states. If you are
 * using only commands or only states, there are other functions you can use
 * instead.
 *
 * Parameters:
 *    EnumCommands = The enumeration defining the constants used to identify
 *       your high-level input commands.
 *    EnumStates = The enumeration defining the constants used to identify
 *       your input states.
 *
 * See_also: initInputCommandsConstants, initInputStatesConstants.
 */
void initInputConstants(EnumCommands, EnumStates)()
   if (is(EnumCommands == enum) && is(EnumStates == enum))
{
   initInputCommandsConstants!EnumCommands();
   initInputStatesConstants!EnumStates();
}


/**
 * Similar to $(D initInputConstants()), but usable when only input commands
 * (and not input states) are needed.
 */
void initInputCommandsConstants(EnumCommands)()
   if (is(EnumCommands == enum))
{
   InputManager.clearCommandMappings();
   foreach (member; EnumMembers!EnumCommands)
      InputManager.addCommandMapping(to!string(member), member);
}


/**
 * Similar to $(D initInputConstants()), but usable when only input states
 * (and not input commands) are needed.
 */
void initInputStatesConstants(EnumStates)()
   if (is(EnumStates == enum))
{
   InputManager.clearStateMappings();
   foreach (member; EnumMembers!EnumStates)
      InputManager.addStateMapping(to!string(member), member);
}



/**
 * The type of functions (er, delegates) used to handle high-level commands.
 *
 * The function receives a single parameter: the event structure describing it
 * in detail.
 */
public alias void delegate(in ref InputHandlerParam param) CommandHandler;

/**
 * An opaque identifier identifying a high-level command handler added to the
 * Input Manager. It can be used to remove the handler.
 */
alias size_t CommandHandlerID;

/**
 * A $(D CommandHandlerID) that is guaranteed to be different to all real $(D
 * CommandHandlerID)s. It is safe to pass this value to $(D
 * InputManager.removeCommandHandler()); it will do nothing in this case.
 */
public immutable CommandHandlerID InvalidCommandHandlerID = 0;


/**
 * The real implementation of the Input Manager. Users shall use this through
 * the $(D InputManager) class.
 *
 * Two kinds of input are supported by the Input Manager:
 *
 * $(OL
 *    $(LI Commands. These are high-level game events, which are handled in a
 *       similar fashion to other events in FewDee. Just use $(D
 *       addCommandTrigger()) to map low-level events to high-level commands and
 *       $(D addCommandHandler()) to add handlers.)
 *    $(LI Input States. Sometimes we don't want to handle input as events; we
 *       just want to have some values that get updated in response to low-level
 *       input events. An input event (see $(D InputState)) is just
 *       that. Use $(D addState()) to add an input state to the Input Manager.)
 * )
 */
private class InputManagerImpl: LowLevelEventHandler
{
   /// Constructs the Input Manager.
   public this()
   {
      if (Engine.requestedFeatures & Features.JOYSTICK)
         rescanJoysticks();
   }


   //
   // High-Level Input Commands
   //

   /**
    * Adds a mapping between a high-level command and an $(D
    * InputTrigger). After this call, whenever that $(D InputTrigger) triggers,
    * that command will be issued.
    *
    * Parameters:
    *    command = The high-level command. If you want to write understandable
    *       code, this will be a value from an $(D enum) that lists all your
    *       commands. (By the way, that's the same $(D enum) you passed to $(D
    *       initInputConstants()) or $(D initInputCommandsConstants()) -- I
    *       mean, you did the Right Thing and called one of them, didn't you?)
    *    trigger = The input trigger.
    *
    * Returns:
    *    An opaque ID that can be passed to $(D removeCommandTrigger()) if you
    *    wish to remove this mapping.
    */
   public final TriggerID addCommandTrigger(int command, InputTrigger trigger)
   {
      return _commandTriggers.add(command, trigger);
   }

   /**
    * Removes a mapping previously added by $(D addCommandTrigger()).
    *
    * Parameters:
    *    triggerID = The ID of the mapping you want to remove; that's what $(D
    *       addCommandTrigger()) returned.
    *
    * Returns:
    *    $(D true) if the mapping was removed; $(D false) if it was not (which
    *    means that a mapping with the provided ID wasn't found).
    */
   public final bool removeCommandTrigger(TriggerID triggerID)
   {
      return _commandTriggers.remove(triggerID);
   }

   /// The collection of command triggers.
   private
      BucketedCollection!(InputTrigger, int, TriggerID, InvalidTriggerID + 1)
         _commandTriggers;

   /**
    * Adds a command handler, that gets called when a certain high-level command
    * is issued.
    *
    * Parameters:
    *    command = The high-level command to handle. (This usually comes from an
    *       $(D enum)).
    *    handler = The handler that will handle the high-level command.
    *
    * Returns:
    *    An opaque ID that can be passed to $(D removeCommandHandler()) in order
    *    to remove the command handler you just added.
    */
   public final CommandHandlerID addCommandHandler(
      int command, CommandHandler handler)
   {
      return _commandHandlers.add(command, handler);
   }

   /**
    * Removes a handler from the collection of high-level command handlers.
    *
    * Parameters:
    *    handlerID = The ID of the handler to remove. If there is no handler
    *       with this ID, nothing happens. (Corollary: you can safely pass $(D
    *       InvalidCommandHandlerID) here; nothing will happen in this case.)
    *
    * Returns:
    *    $(D true) if the handler was removed; $(D false) if not (which means
    *    that no handler with the given ID was found).
    */
   public final bool removeCommandHandler(CommandHandlerID handlerID)
   {
      return _commandHandlers.remove(handlerID);
   }

   /// The collection of command handlers.
   private
      BucketedCollection!(CommandHandler, int, CommandHandlerID,
                          InvalidCommandHandlerID + 1)
         _commandHandlers;

   /**
    * Disables some high-level commands.
    *
    * This will stop the input triggers of these commands to run, and therefore
    * no commands of these types will be triggered.
    *
    * Parameters:
    *    commands = The commands to disable.
    *
    * See_also: enableCommands
    */
   public final void disableCommands(int[] commands...)
   {
      foreach (command; commands)
         _disabledCommands[command] = true;
   }

   /**
    * Enables some commands.
    *
    * All commands are enabled by default. You only need to call this if you
    * disabled the commands by calling $(D disableCommands()).
    *
    * It is OK to enable commands that are already enabled.
    *
    * Parameters:
    *    commands = The commands to enable.
    *
    * See_also: disableCommands
    */
   public final void enableCommands(int[] commands...)
   {
      foreach (command; commands)
         _disabledCommands.remove(command);
   }

   /**
    * The list of disabled high-level commands.
    *
    * The Boolean value is ignored; only the key matters here.
    */
   private bool[int] _disabledCommands;


   //
   // Input States
   //

   /**
    * Adds a new input state to the Input Manager.
    *
    * Trying to add two states with the same "ID" (the constant that identifies
    * it) is an error.
    *
    * Parameters:
    *    stateID = The constant that identifies the state being added. This
    *       should come from the same $(D enum) passed to $(D
    *       initInputConstants()) or $(D initInputStatesConstants()).
    *    state = The state object itself.
    */
   public final void addState(int stateID, InputState state)
   in
   {
      assert(stateID !in _states);
      assert(state !is null);
   }
   body
   {
      _states[stateID] = state;
   }

   /**
    * Returns a given input state.
    *
    * Notice that you'll need to downcast the returned $(D InputState) to the
    * proper subclass in order to actually read the state. You may wish to
    * encapsulate this call and the cast into something else to make your code
    * cleaner. But, hey!, that's your code; this is just a suggestion.
    *
    * Parameters:
    *    state = The constant identifying the state to query. This should come
    *       from the same $(D enum) passed to $(D initInputConstants()) or $(D
    *       initInputStatesConstants()).
    *
    * Returns:
    *    The input state associated with $(state). If no input state was
    *    associated with $(state), returns $(D null).
    */
   public final @property const(InputState) state(int state) const
   {
      const s = state in _states;
      if (s)
         return *s;
      else
         return null;
   }

   /// The collection of input states.
   private InputState[int] _states;


   //
   // Joysticks
   //

   /// Information about a joystick.
   public struct JoyInfo
   {
      /// The joystick name
      public string name;

      /**
       * An array with the button names of this joystick.
       *
       * Its length tells how many buttons the joystick has.
       *
       * The array is sorted so that the array indices are the same as the
       * integer values identifying joystick buttons that are passed to other
       * FewDee functions.
       */
      public string[] buttons;

      /**
       * An array with the names of the joystick axes.
       *
       * Its length tells how many axes the joystick has.
       *
       * Notice that, unlike Allegro, FewDee doesn't group axes in sticks.
       *
       * The array is sorted so that the array indices are the same as the
       * integer values identifying joystick axes that are passed to other
       * FewDee functions.
       */
      public string[] axes;

      /**
       * A pair of integers used to identify a joystick axis; the first is
       * interpreted as the Allegro joystick stick index; the second as the
       * Allegro axis index.
       */
      private alias Tuple!(int,int) stickAxis;

      /**
       * Mapping between axes as used in Allegro (stick index plus axis index)
       * and in FewDee (a single axis index).
       */
      private BiMap!(stickAxis, int) _axisToStickAndAxis;
   }

   /**
    * Returns an array with information about all connected joysticks.
    *
    * Notice that joysticks may be connected or disconnected at any time, but
    * the list returned by this function will be updated only after $(D
    * rescanJoysticks()) is called.
    *
    * The array is sorted so that the array indices are the same as the integer
    * values identifying joysticks that are passed to other FewDee functions.
    *
    * See_also: rescanJoysticks
    */
   public final @property const(JoyInfo[]) joysticks() inout
   {
      return _joyData;
   }

   /**
    * Rescans the system looking for joysticks.
    *
    * You may want to call this upon entering a "configure input" screen (and,
    * perhaps, whenever the Allegro event $(D
    * ALLEGRO_EVENT_JOYSTICK_CONFIGURATION) is triggered).
    *
    * Returns:
    *    An array describing the joysticks found.
    */
   public final const(JoyInfo[]) rescanJoysticks()
   {
      if (al_reconfigure_joysticks() || _joyData.length == 0)
      {
         const numJoys = al_get_num_joysticks();
         _joyData.length = numJoys;

         foreach (i; 0..numJoys)
         {
            // Name
            auto joy = al_get_joystick(i);
            _joyIndex[joy] = i;
            _joyData[i].name = to!string(al_get_joystick_name(joy));

            // Buttons
            const numButtons = al_get_joystick_num_buttons(joy);
            _joyData[i].buttons.length = numButtons;
            foreach(j; 0..numButtons)
            {
               _joyData[i].buttons[j] =
                  to!string(al_get_joystick_button_name(joy, j));
            }

            // Axes
            const numSticks = al_get_joystick_num_sticks(joy);
            _joyData[i].axes.length = 0;
            _joyData[i]._axisToStickAndAxis.clear();

            foreach(j; 0..numSticks)
            {
               const numAxes = al_get_joystick_num_axes(joy, j);
               const stickName = to!string(al_get_joystick_stick_name(joy, j));

               foreach(k; 0..numAxes)
               {
                  _joyData[i].axes ~= stickName ~ "/"
                     ~ to!string(al_get_joystick_axis_name(joy, j, k));

                  const serial = _joyData[i].axes.length - 1;
                  _joyData[i]._axisToStickAndAxis[serial] =
                     JoyInfo.stickAxis(j, k);
               }
            }
         }
      }

      return _joyData;
   }

   /**
    * Returns the joystick ID (sequential number, starting from zero) that
    * corresponds to a given joystick.
    */
   package final int joyID(const ALLEGRO_JOYSTICK* joy) inout
   {
      return _joyIndex[joy];
   }

   /**
    * Returns the joystick axis ID (sequential number, starting from zero) that
    * corresponds to a given joystick, stick and axis.
    *
    * Parameters:
    *    joy = The FewDee "sequential ID" of desired joystick.
    *    stick = The Allegro stick ID.
    *    axis = The Allegro axis ID.
    *
    * Returns:
    *    The FewDee sequential "axis ID".
    */
   package final int joyAxisID(int joy, int stick, int axis) inout
   {
      return _joyData[joy]._axisToStickAndAxis[JoyInfo.stickAxis(stick, axis)];
   }

   /**
    * An array describing the joysticks found in the system.
    *
    * This is updated only when $(D rescanJoysticks()) is called.
    */
   private JoyInfo[] _joyData;

   /**
    * Given an $(D ALLEGRO_JOYSTICK*), yields the joystick "sequential number".
    *
    * This is updated only when $(D rescanJoysticks()) is called.
    */
   private int[ALLEGRO_JOYSTICK*] _joyIndex;


   //
   // Memento-Like Interface
   //

   /**
    * Clears the mappings between the values and strings representing high-level
    * commands.
    */
   private final void clearCommandMappings()
   {
      _commandMappings.clear();
   }

   /**
    * Clears the mappings between the values and strings representing input
    * states.
    */
   private final void clearStateMappings()
   {
      _stateMappings.clear();
   }

   /**
    * Adds a mapping between a value and a string representing a high-level
    * command.
    */
   private final void addCommandMapping(in string name, int value)
   {
      _commandMappings[name] = value;
   }

   /// Adds a mapping between a value and a string representing an input state.
   private final void addStateMapping(in string name, int value)
   {
      _stateMappings[name] = value;
   }

   /**
    * A representation of the configuration of the $(D InputManager) related to
    * input commands and input states.
    *
    * This implements something akin to the Memento pattern. You can read this
    * property to obtain a somewhat opaque representation of the configuration
    * of the $(D InputManager) and write to it to restore a previous
    * configuration.
    */
   public final @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();

      ConfigValue commands;
      commands.makeAA();
      c["commands"] = commands;

      ConfigValue states;
      states.makeAA();
      c["states"] = states;

      // Commands
      const commandIDs = _commandTriggers.buckets();

      foreach (commandID; commandIDs)
      {
         const strCommandID = _commandMappings[commandID];
         c["commands"][strCommandID].makeList();
         int i = 0;
         foreach(trigger; _commandTriggers.get(commandID))
            c["commands"][strCommandID][i++] = trigger.memento;
      }

      // States
      foreach (stateID, state; _states)
      {
         const strStateID = _stateMappings[stateID];
         c["states"][strStateID] = state.memento;
      }

      // Here we go!
      return c;
   }

   /// Ditto.
   public final @property void memento(const ConfigValue state)
   {
      enforce(hasPossiblyEmptyAA(state, "commands"));
      enforce(hasPossiblyEmptyAA(state, "states"));

      clearCommandTriggersAndStates();

      // Command triggers
      if (!state["commands"].isEmptyTable)
      {
         foreach (strCommandID; state["commands"].asAA.keys)
         {
            const commandID = _commandMappings[strCommandID];

            foreach (cfgTrigger; state["commands"][strCommandID].asList)
            {
               auto objTrigger = makeInputTrigger(cfgTrigger);
               addCommandTrigger(commandID, objTrigger);
            }
         }
      }

      // States
      if (!state["states"].isEmptyTable)
      {
         foreach (strStateID; state["states"].asAA.keys)
         {
            const stateID = _stateMappings[strStateID];
            const cfgState = state["states"][strStateID];
            auto objState = makeInputState(cfgState);
            addState(stateID, objState);
         }
      }
   }

   /**
    * Mapping of high-level command strings to their integer values.
    *
    * This is used by the memento-like mechanism, which needs to translate
    * between the values in the $(D enum) that lists all the high-level commands
    * and their representation as a string.
    */
   private BiMap!(int,string) _commandMappings;

   /**
    * Mapping of input state strings to their integer values.
    *
    * This is used by the memento-like mechanism, which needs to translate
    * between the values in the $(D enum) that lists all the input states and
    * their representation as a string.
    */
   private BiMap!(int,string) _stateMappings;


   //
   // Event Handling
   //

   /**
    * Called when an event (any event) is received.
    *
    * Updates the input states and calls the command handlers.
    *
    * Parameters:
    *    event = The event received.
    */
   public final override void handleEvent(in ref ALLEGRO_EVENT event)
   {
      // Update states
      foreach (state; _states)
         state.update(event);

      // Handle high-level commands
      foreach (commandID; _commandTriggers.buckets)
      {
         // Ignore disabled commands
         if (commandID in _disabledCommands)
            continue;

         // Execute triggers, call handlers
         foreach (trigger; _commandTriggers.get(commandID))
         {
            InputHandlerParam param;
            if (trigger.didTrigger(event, param))
            {
               // Call handlers
               foreach (handler; _commandHandlers.get(commandID))
                  handler(param);
            }
         }
      }
   }


   //
   // Assorted utilities
   //

   /// Clears all command triggers and states.
   public final void clearCommandTriggersAndStates()
   {
      _commandTriggers = typeof(_commandTriggers).init;
      _states = typeof(_states).init;
   }

   /// Obtains the input source of a given Allegro event.
   public final InputSource inputSource(in ref ALLEGRO_EVENT event)
   {
      switch (event.type)
      {
         case ALLEGRO_EVENT_KEY_DOWN:
         case ALLEGRO_EVENT_KEY_UP:
         case ALLEGRO_EVENT_KEY_CHAR:
            return InputSource.KEYBOARD;

         case ALLEGRO_EVENT_MOUSE_AXES:
         case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
         case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
         case ALLEGRO_EVENT_MOUSE_WARPED:
         case ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY:
         case ALLEGRO_EVENT_MOUSE_LEAVE_DISPLAY:
            return InputSource.MOUSE;

         case ALLEGRO_EVENT_JOYSTICK_AXIS:
         case ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN:
         case ALLEGRO_EVENT_JOYSTICK_BUTTON_UP:
            return cast(InputSource)
               (InputSource.JOY0 + _joyIndex[event.joystick.id]);

         default:
            return InputSource.INVALID;
      }
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
