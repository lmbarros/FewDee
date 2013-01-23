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
 * A structure passed as parameter to handler of high-level commands. Its fields
 * are just generic data fields, and shouldn't be used directly. Instead, FewDee
 * provides some magic that allows to read from and write to these fields using
 * more meaningful names, like sourceIsMouse or sourceIsKeyboard.
 */
struct HighLevelCommandCallbackParam
{
   /**
    * This is the source of the command. For mouse events, this will be
    * al_get_mouse_event_source(). For keyboard events, it will be
    * al_get_keyboard_event_source(). For joystick events, it will be the
    * ALLEGRO_JOYSTICK* (returned by al_get_joystick()).
    */
   private void* source;
}


/// Was the command generated by the mouse?
@property bool sourceIsMouse(const ref HighLevelCommandCallbackParam param)
{
   return param.source == al_get_mouse_event_source();
}


/// Was the command generated by the keyboard?
@property bool sourceIsKeyboard(const ref HighLevelCommandCallbackParam param)
{
   return param.source == al_get_keyboard_event_source();
}


/// Was the command generated by a given joystick?
bool sourceIsJoystick(const ref HighLevelCommandCallbackParam param,
                                ALLEGRO_JOYSTICK* joystick)
{
   return param.source == joystick;
}


/// A delegate used to handle high-level commands.
alias void delegate(in ref HighLevelCommandCallbackParam param)
   HighLevelCommandCallback_t;


/**
 * A CommandTrigger_t is a delegate that verifies if a given low-level Allegro
 * event has triggered a specific high-level command. The event parameter is the
 * low-level Allegro event. In the param parameter, the delegate passes whatever
 * it wants to be passed to whoever will handle the high-level command. A
 * CommandTrigger_t shall return true the low-level has triggered the high-level
 * command it is trying to recognize, or false otherwise.
 */
alias
   bool delegate(in ref ALLEGRO_EVENT event,
                 out HighLevelCommandCallbackParam param)
   CommandTrigger_t;


/**
 * Creates a command trigger that triggers a high-level command in response to
 * key presses.
 */
CommandTrigger_t keyPress(int keyCode)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_DOWN
          && event.keyboard.keycode == keyCode)
      {
         param.source = al_get_keyboard_event_source();
         return true;
      }

      return false;
   };
}


/**
 * Creates a command trigger that triggers a high-level command in response to a
 * joystick button press.
 */
CommandTrigger_t joyButtonPress(int button)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && event.joystick.button == button)
      {
         param.source = cast(void*)(event.joystick.id);
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
class AbstractedInput(HighLevelCommandsEnum)
   if (is(HighLevelCommandsEnum == enum))
      : EventHandler
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

            // Give a chance to more high-level commands to be executed. Perhaps
            // this should be replaceable with a 'break' by passing a certain
            // template parameter (in order to implement a policy of a low-level
            // event can trigger only one high-level command).
            continue;
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
    */
   public void addMapping(CommandTrigger_t lowLevelCommand,
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
      public CommandTrigger_t lowLevelCommand;
      public HighLevelCommandsEnum highLevelCommand;
   }

   /// All the mappings from low-level to a high-level commands.
   mapping_t[] mappings_;

   /**
    * The callbacks to be called in response to high-level commands. This is a
    * map, indexed by the high-level command. It value is an array containing
    * all the callbacks to be called when that high-level command is triggered.
    */
   HighLevelCommandCallback_t[][HighLevelCommandsEnum] callbacks_;
}
