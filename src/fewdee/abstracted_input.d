/**
 * Abstracted input. Translates low-level input events like "pressed space" and
 * "moved joystick a bit to the right" to high-level commands like "jump" and
 * "walk right".
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.abstracted_input;

import allegro5.allegro;
import fewdee.event_handler;

/**
 * The input devices that can generate hi-level events. This is useful to
 * detect, for example, if that "fire" command was issued by the player using
 * the keyboard or the player using the joystick.
 *
 * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 * xxxxxxx Think about what to do when joysticks are inserted or removed; their
 * "joystick number" can change, I suppose. Supporting joystick being added or
 * removing during gameplay may be unnecessary, but during setup is essential
 * (and from the library perspective, there is no difference between setup and
 * gameplay...)
 */
enum InputDevice
{
   /// Used when the command doesn't come from any specific device.
   NONE,

   /// Keyboard.
   KEYBOARD,

   /// Mouse. Or any device posing as a mouse, like a notebook touch pad.
   MOUSE,

   /// The first joystick.
   JOYSTICK_0,

   /// The second joystick.
   JOYSTICK_1,

   /// The third joystick.
   JOYSTICK_2,

   /// The fourth joystick.
   JOYSTICK_3,

   /// The fifth joystick.
   JOYSTICK_4,

   /// The sixth joystick.
   JOYSTICK_5,

   /// The seventh joystick.
   JOYSTICK_6,

   /// The eight joystick.
   JOYSTICK_7,

   /// The ninth joystick.
   JOYSTICK_8,

   /// The tenth joystick.
   JOYSTICK_9,
}


/**
 * A structure passed as parameter to handler of high-level commands. With the
 * exception of the source field, its fields are just generic data fields, and
 * shouldn't be used directly. Instead, FewDee provides some magic that allows
 * to read from and write to these fields using more meaningful names.
 *
 * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 * xxxxxxxxx Mention examples of the magic properties
 */
struct HighLevelCommandCallbackParam
{
   /// This is the source of the command.
   InputDevice source;

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // xxxxxx These are dummy fields
   float f1;
   float f2;
   int i1;
   int i2;
}


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxx dummy!
@property void someParam(ref HighLevelCommandCallbackParam param, int value)
{
   param.i1 = value;
}

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxx dummy!
@property int someParam(ref HighLevelCommandCallbackParam param)
{
   return param.i1;
}


/// The type used by delegates that are used to handle high-level commands.
alias void delegate(in ref HighLevelCommandCallbackParam param)
   HighLevelCommandCallback_t;


/**
 * A CommandTranslator_t is a delegate that verifies if a low-level Allegro
 * event can be translated to a specific high-level command. The event parameter
 * is the low-level Allegro event. In the param parameter, the delegate passes
 * whatever it wants to be passed to whoever will handle the high-level
 * command. A CommandTranslator_t shall return true if it recognized the
 * low-level event as the high-level command it is trying to recognize, or false
 * otherwise.
 *
 * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 * xxxxxx rename to CommandTrigger_t?
 */
alias
   bool delegate(in ref ALLEGRO_EVENT event,
                 out HighLevelCommandCallbackParam param)
   CommandTranslator_t;


/**
 * Creates a command translator that recognizes key presses as the low-level
 * event.
 */
CommandTranslator_t keyPress(int keyCode)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_DOWN
          && event.keyboard.keycode == keyCode)
      {
         param.source = InputDevice.KEYBOARD;
         param.someParam = 123; // xxxxxx dummy xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
         return true;
      }

      return false;
   };
}


/**
 * Creates a command translator that recognizes joystick button presses as the
 * low-level event.
 */
CommandTranslator_t joyButtonPress(int button)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && event.joystick.button == button)
      {
         // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
         // xxxxxxxx actually, JOYSTICK_0 + theJoystick
         param.source = InputDevice.JOYSTICK_0;
         return true;
      }

      return false;
   };
}


/**
 * An EventHandler that listens to low-level events, checks if they trigger
 * high-level commands and, if they do, call the handlers of these high-level
 * commands.
 */
class AbstractedInput(HighLevelCommandsEnum): EventHandler
   // if isEnum(HighLevelCommandsEnum)  // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
{
   /**
    * Handles the low-level events. Calls the high-level handlers, if
    * appropriate.
    */
   public bool handleEvent(in ref ALLEGRO_EVENT event)
   {
      bool eventHandled = false;

      foreach (mapping; mappings_)
      {
         HighLevelCommandCallbackParam param;
         if (mapping.lowLevelCommand(event, param))
         {
            if (mapping.highLevelCommand in callbacks_)
            {
               // call callbacks
               foreach(callback; callbacks_[mapping.highLevelCommand])
                  callback(param);

               eventHandled = true;
            }

            // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            continue; // xxxxxxxx or break?!
         }
      }

      return eventHandled;
   }


   /// Removes all the mappings from low-level events to high-level commands.
   public void clearMappings()
   {
      mappings_ = [ ];
   }


   /**
    * Adds a new mapping from a low-level event to a high-level command.
    *
    * Parameters:
    *    lowLevelCommand = A delegate that checks if the desired low-level
    *       command was issued.
    *    highLevelCommand = The high-level command to trigger when the
    *       lowLevelCommand is issued.
    *
    * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    * xxxxxxxxxxxx return something identifying the mapping, so that we can
    * remove it afterward
    */
   public void addMapping(CommandTranslator_t lowLevelCommand,
                          HighLevelCommandsEnum highLevelCommand)
   {
      mappings_ ~= mapping_t(lowLevelCommand, highLevelCommand);
   }

   /**
    * Adds a new callback that will be called whenever a given high-level
    * command is triggered.
    *
    * Parameters:
    *    highLevelCommand = The desired high-level command.
    *    ccb = The function (er, delegate) to call when highLevelCommand is
    *       triggered.
    */
   public void addCallback(HighLevelCommandsEnum highLevelCommand,
                           HighLevelCommandCallback_t ccb)
   {
      callbacks_[highLevelCommand] ~= ccb;
   }

   /// A structure storing one mapping from a low-level to a high-level command.
   private struct mapping_t
   {
      public CommandTranslator_t lowLevelCommand;
      public HighLevelCommandsEnum highLevelCommand;
   }

   /// All the mappings from low-level to a high-level commands.
   mapping_t[] mappings_;

   /**
    * The callbacks to be called in response to high-level commands. This is a
    * map, indexed by the high-level command. It value is an array containing
    * all the callbacks to be called when that high-level command is triggered.
    *
    * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    * xxxxx BTW, what if we add a callback but don't add a mapping? Must add
    * this to a test case; it shouldn't break, at least.
    */
   HighLevelCommandCallback_t[][HighLevelCommandsEnum] callbacks_;
}
