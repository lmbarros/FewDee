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
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this() { }

   /**
    * Constructs the trigger.
    *
    * Parameters:
    *    keyCode = The keycode (an $(D ALLEGRO_KEY_*) constant) this trigger is
    *       listening to.
    */
   public this(int keyCode)
   {
      _keyCode = keyCode;
   }

   // Inherit docs.
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

   // Inherit docs.
   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this() { }

   /**
    * Constructs the trigger.
    *
    * Parameters:
    *    keyCode = The keycode (an $(D ALLEGRO_KEY_*) constant) this trigger is
    *       listening to.
    */
   public this(int keyCode)
   {
      _keyCode = keyCode;
   }

   // Inherit docs.
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

   // Inherit docs.
   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this() { }

   /**
    * Constructs the trigger.
    *
    * Parameters:
    *    joy = The joystick to listen to. Valid joysticks are numbered from $(D
    *       1) ($(D 0) is reserved to mean "invalid joystick").
    *    button = The button to listen to. Valid buttons are numbered from $(D
    *       0) ($(D 0) is reserved to mean "invalid button").
    */
   public this(int joy, int button)
   {
      _joy = joy;
      _button = button;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && InputManager.joystickID(event.joystick.id) == _joy
          && event.joystick.button == _button - 1)
      {
         param.source =
            cast(InputSource)((InputSource.JOYSTICK1 << (_joy - 1)));
         return true;
      }

      return false;
   }

   // Inherit docs.
   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   /**
    * The joystick this trigger is watching.
    *
    * $(D 0) means "invalid joystick".
    */
   public final @property int joy() inout
   {
      return _joy;
   }

   /// Ditto.
   public final @property void joy(int joy)
   {
      _joy = joy;
   }

   /// Ditto.
   private int _joy = 0;

   /**
    * The joystick button this trigger is watching.
    *
    * $(D 0) means "invalid button".
    */
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
   private int _button = 0;
}



// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxxx maybe: JoyAxis{Enter,Leave}{Pos,Neg} (axis, threshold = 0.5) // only axis, no stick+axis (SDL compatibility)

// as in "key up" and "key down".
// JoyPosAxisDown
// JoyPosAxisUp
// JoyNegAxisDown
// JoyUpAxisNeg


// xxxxxxxxx bad name xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
/**
 * An input trigger that triggers when a certain joystick axis' value crosses a
 * certain threshold value while increasing.
 */
class JoyAxisIncreaseTrigger: InputTrigger
{
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this() { }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int stick, int axis, float threshold)
   {
      _stick = stick;
      _axis = axis;
      _threshold = threshold;
   }

   // Inherit docs.
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
            param.source = InputSource.JOYSTICK1; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this() { }

   // xxxxxxxx As config string only? No, I guess... xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public this(int stick, int axis, float threshold)
   {
      _stick = stick;
      _axis = axis;
      _threshold = threshold;
   }

   // Inherit docs.
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
            param.source = InputSource.JOYSTICK1; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
