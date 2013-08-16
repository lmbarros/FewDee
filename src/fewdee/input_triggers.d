/**
 * A collection of ready-to-use $(D InputTrigger)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_triggers;

import allegro5.allegro;
import fewdee.config;
import fewdee.input_manager;


/// An input trigger that triggers when a certain keyboard key is pressed.
class KeyDownTrigger: InputTrigger
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this()
   {
   }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int keyCode)
   {
      _keyCode = keyCode;
   }

   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_DOWN
          && event.keyboard.keycode == _keyCode)
      {
         param.source = InputSource.KEYBOARD;
         return true;
      }

      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // nothing...
   }

   /**
    * The key code this trigger is watching (an $(D ALLEGRO_KEY_*) constant).
    *
    * If equals to $(D ALLEGRO_KEY_MAX), this means that no real key is being
    * "watched", and the trigger will never trigger.
    */
   public final @property int keyCode() inout
   {
      return _keyCode;
   }

   /// Ditto.
   public final @property void keyCode(int keyCode)
   {
      _keyCode = keyCode;
   }

   /// Ditto.
   private int _keyCode = ALLEGRO_KEY_MAX;
}

/// An input trigger that triggers when a certain keyboard key is released.
class KeyUpTrigger: InputTrigger
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this()
   {
   }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int keyCode)
   {
      _keyCode = keyCode;
   }

   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_UP
          && event.keyboard.keycode == _keyCode)
      {
         param.source = InputSource.KEYBOARD;
         return true;
      }

      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // nothing...
   }

   /**
    * The key code this trigger is watching (an $(D ALLEGRO_KEY_*) constant).
    *
    * If equals to $(D ALLEGRO_KEY_MAX), this means that no real key is being
    * "watched", and the trigger will never trigger.
    */
   public final @property int keyCode() inout
   {
      return _keyCode;
   }

   /// Ditto.
   public final @property void keyCode(int keyCode)
   {
      _keyCode = keyCode;
   }

   /// Ditto.
   private int _keyCode = ALLEGRO_KEY_MAX;
}


/// An input trigger that triggers when a certain joystick button is pressed.
class JoyButtonDownTrigger: InputTrigger
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this()
   {
   }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int button)
   {
      _button = button;
   }

   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && event.joystick.button == _button)
      {
         param.source = InputSource.JOYSTICK0; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
         return true;
      }

      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // nothing...
   }

   /// The joystick button this trigger is watching.
   public final @property int button() inout
   {
      return _button;
   }

   /// Ditto.
   public final @property void button(int button)
   {
      _button = button;
   }

   /// Ditto.
   private int _button = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
}


// xxxxxxxxx bad name xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
/**
 * An input trigger that triggers when a certain joystick axis' value crosses a
 * certain threshold value while increasing.
 */
class JoyAxisIncreaseTrigger: InputTrigger
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this()
   {
   }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int stick, int axis, float threshold)
   {
      _stick = stick;
      _axis = axis;
      _threshold = threshold;
   }

   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && event.joystick.stick == _stick
          && event.joystick.axis == _axis)
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue <= _threshold && currValue > _threshold)
         {
            param.source = InputSource.JOYSTICK0; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            return true;
         }
      }

      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // nothing...
   }

   /// The joystick stick this trigger is watching.
   public final @property int stick() inout
   {
      return _stick;
   }

   /// Ditto.
   public final @property void stick(int stick)
   {
      _stick = stick;
   }

   /// Ditto.
   private int _stick = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   /// The joystick axis this trigger is watching.
   public final @property int axis() inout
   {
      return _axis;
   }

   /// Ditto.
   public final @property void axis(int axis)
   {
      _axis = axis;
   }

   /// Ditto.
   private int _axis = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   /// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final @property float threshold() inout
   {
      return _threshold;
   }

   /// Ditto.
   public final @property void threshold(float threshold)
   {
      _threshold = threshold;
   }

   /// Ditto.
   private float _threshold = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   private float _prevValue = 0.0;
}


// xxxxxxxxx bad name xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
/**
 * An input trigger that triggers when a certain joystick axis' value crosses a
 * certain threshold value while decreasing.
 */
class JoyAxisDecreaseTrigger: InputTrigger
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this()
   {
   }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int stick, int axis, float threshold)
   {
      _stick = stick;
      _axis = axis;
      _threshold = threshold;
   }

   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && event.joystick.stick == _stick
          && event.joystick.axis == _axis)
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue >= _threshold && currValue < _threshold)
         {
            param.source = InputSource.JOYSTICK0; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            return true;
         }
      }

      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // nothing...
   }

   /// The joystick stick this trigger is watching.
   public final @property int stick() inout
   {
      return _stick;
   }

   /// Ditto.
   public final @property void stick(int stick)
   {
      _stick = stick;
   }

   /// Ditto.
   private int _stick = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   /// The joystick axis this trigger is watching.
   public final @property int axis() inout
   {
      return _axis;
   }

   /// Ditto.
   public final @property void axis(int axis)
   {
      _axis = axis;
   }

   /// Ditto.
   private int _axis = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   /// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final @property float threshold() inout
   {
      return _threshold;
   }

   /// Ditto.
   public final @property void threshold(float threshold)
   {
      _threshold = threshold;
   }

   /// Ditto.
   private float _threshold = -1; // xxxxxxxxxx meaning of -1? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   private float _prevValue = 0.0;
}
