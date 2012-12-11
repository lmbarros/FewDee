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


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxx plus some @property usable with UFCS...
struct HighLevelCommandCallbackParam
{
   float f1;
   float f2;
   int i1;
   int i2;
   // xxxxxxxx IOW, whatever is needed.
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



alias void delegate(in ref HighLevelCommandCallbackParam param)
   HighLevelCommandCallback_t;


alias bool delegate(in ref ALLEGRO_EVENT event,
                    out HighLevelCommandCallbackParam param)
   CommandTranslator_t;


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxx kinda dummy!
CommandTranslator_t keyPress(int keyCode)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_DOWN
          && event.keyboard.keycode == keyCode)
      {
         param.someParam = 123; // xxxxxx dummy xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
         return true;
      }

      return false;
   };
}


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxx kinda dummy! Which joystick?
CommandTranslator_t joyButtonPress(int button)
{
   return delegate(in ref ALLEGRO_EVENT event,
                   out HighLevelCommandCallbackParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && event.joystick.button == button)
      {
         return true;
      }

      return false;
   };
}


class AbstractedInput(HighLevelCommandsEnum): EventHandler
   // if isEnum(HighLevelCommandsEnum)  // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
{
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

   public void clearMappings()
   {
      mappings_ = [ ];
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // xxxxxxxxxxxx return something identifying the mapping, so that we can
   // remove it afterward
   public void addMapping(CommandTranslator_t lowLevelCommand,
                          HighLevelCommandsEnum highLevelCommand)
   {
      mappings_ ~= mapping_t(lowLevelCommand, highLevelCommand);
   }

   public void addCallback(HighLevelCommandsEnum highLevelCommand,
                           HighLevelCommandCallback_t ccb)
   {
      callbacks_[highLevelCommand] ~= ccb;
   }


   private struct mapping_t
   {
      public CommandTranslator_t lowLevelCommand;
      public HighLevelCommandsEnum highLevelCommand;
   }

   mapping_t[] mappings_;

   HighLevelCommandCallback_t[][HighLevelCommandsEnum] callbacks_;
}
