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
 * Authors: Leandro Motta Barros
 */

module fewdee.input_manager;

import std.conv;
import std.traits;
import allegro5.allegro;
import fewdee.config;
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
   INVALID = 0,         /// An invalid input source.
   GUI = 1 << 1,        /// The event was generated via GUI widgets
   KEYBOARD = 1 << 2,   /// The keyboard.
   MOUSE = 1 << 3,      /// The mouse.
   JOYSTICK0 = 1 << 4,  /// The first joystick.
   JOYSTICK1 = 1 << 5,  /// The second joystick.
   JOYSTICK2 = 1 << 6,  /// The third joystick.
   JOYSTICK3 = 1 << 7,  /// The fourth joystick.
   JOYSTICK4 = 1 << 8,  /// The fifth joystick.
   JOYSTICK5 = 1 << 9,  /// The sixth joystick.
   JOYSTICK6 = 1 << 10, /// The seventh joystick.
   JOYSTICK7 = 1 << 11, /// The eight joystick.
   JOYSTICK8 = 1 << 12, /// The ninth joystick.
   JOYSTICK9 = 1 << 13, /// The tenth joystick.
}



/**
 * A generic structure passed as parameter to input handlers.
 *
 * Please note that this structure has only private members. To access the
 * struct's data, please use the functions designed to extract information from
 * it. (Check the "See also" section.)
 *
 * See_also: source, isSourceGUI, isSourceKeyboard, isSourceMouse,
 *    isSourceJoystick0
 */
public struct InputHandlerParam
{
   /// The event source.
   private InputSource _source;
}

/**
 * Obtains the event source.
 *
 * Technically, the event source is a bitfield, but in most practical cases only
 * one bit will be set.
 */
public @property InputSource source(const InputHandlerParam p)
{
   return p._source;
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
   return p._source == InputSource.JOYSTICK0;
}

/// Ditto.
public bool isSourceJoy1(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK1;
}

/// Ditto.
public bool isSourceJoy2(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK2;
}

/// Ditto.
public bool isSourceJoy3(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK3;
}

/// Ditto.
public bool isSourceJoy4(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK4;
}

/// Ditto.
public bool isSourceJoy5(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK5;
}

/// Ditto.
public bool isSourceJoy6(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK6;
}

/// Ditto.
public bool isSourceJoy7(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK7;
}

/// Ditto.
public bool isSourceJoy8(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK8;
}

/// Ditto.
public bool isSourceJoy9(const InputHandlerParam p)
{
   return p._source == InputSource.JOYSTICK9;
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
   public abstract @property const(ConfigValue) memento();

   /// Ditto.
   public abstract @property void memento(const ConfigValue state);
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
    * This implements something akin to the Memento pattern. You can read this
    * property to obtain a somewhat opaque representation of the configuration
    * of this $(D InputState) and write to it to restore a previous
    * configuration.
    */
   public abstract @property const(ConfigValue) memento();

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



// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// Maybe not a good name. This is to implement those "configure keys"
// screens. Create it, reset() it and keep checking if hasCommand(). When it
// has, just taje the command(). Maybe will need a way to set a "cancel" command
// ("press ESC to not read any command").
// And... move to a separate file?
class CommandListener: LowLevelEventHandler
{
   // clears the current command
   public void reset() { };
   public @property bool hasCommand() { return false; }

   // What to return here?
   public @property int command() { return 0; };
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

   // mappings between command enum names and enum values
   private final void clearCommandMappings()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // mappings between command enum names and enum values
   private final void clearStateMappings()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // mappings between command enum names and enum values
   private final void addCommandMapping(in string name, int value)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // mappings between command enum names and enum values
   private final void addStateMapping(in string name, int value)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // commands = {
   //    JUMP = {
   //       -- List of triggers
   //       { type = "fewdee.input_triggers.KeyDown", key = "A" },
   //       { type = "fewdee.input_triggers.KeyDown", key = "Enter" },
   //       { type = "fewdee.input_triggers.JoyDown", joy = 0, button = 2 },
   //    },
   //    FIRE = { } -- no triggers for this command
   // }
   //
   // states = {
   //    THROTTLE = {
   //       type = "fewdee.input_states.FloatInputState",
   //       min = 0.0,
   //       max = 1.0,
   //       default = 0.0,
   //       setValue = {
   //          -- list of triggers
   //          { type = "fewdee.input_triggers.JoyAxis", joy = 0, axis = 1 },
   //          { type = "fewdee.input_triggers.InterpolatingKeys", keys = { "0", "1", "2", "3", "4", "5" } },
   //       }
   //    }
   // }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // Memento! Maybe a better name; 'state' is limited to mappings or so...
   public final @property const(ConfigValue) memento() inout
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   /// Ditto.
   public final @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

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
      foreach (state; _states)
         state.update(event);

      foreach (commandID; _commandTriggers.buckets)
      {
         // Ignore disabled commands
         if (commandID in _disabledCommands)
            break;

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

   /// The collection of command triggers.
   private
      BucketedCollection!(InputTrigger, int, TriggerID, InvalidTriggerID + 1)
         _commandTriggers;

   /// The collection of command handlers.
   private
      BucketedCollection!(CommandHandler, int, CommandHandlerID,
                          InvalidCommandHandlerID + 1)
         _commandHandlers;

   /// The collection of input states.
   private InputState[int] _states;

   /**
    * The list of disabled high-level commands.
    *
    * The Boolean value is ignored; only the key matters here.
    */
   private bool[int] _disabledCommands;
}



/**
 * The Input Manager singleton. Provides access to the one and only $(D
 * InputManagerImpl) instance.
 */
public class InputManager
{
   mixin LowLockSingleton!InputManagerImpl;
}
