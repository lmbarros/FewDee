/**
 * A collection of ready-to-use $(D InputTrigger)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_triggers;

import std.conv;
import std.exception;
import allegro5.allegro;
import fewdee.config;
import fewdee.input_helpers;
import fewdee.input_manager;


//
// Helper mixin templates
//

/// Boilerplate code for input triggers using a key code.
mixin template KeyCodeMixin()
{
   /// Is this trigger watching a given Allegro key code?
   private final bool isSameKeyCode(int keyCode)
   {
      return _keyCode == keyCode;
   }

   /**
    * The key code this trigger is watching; an $(D ALLEGRO_KEY_*) constant.
    *
    * If equals to $(D ALLEGRO_KEY_MAX), this means that no real key is being
    * "watched", and the trigger will never trigger.
    */
   public final @property int keyCode() inout
   {
      return _keyCode;
   }

   /// Ditto
   public final @property void keyCode(int keyCode)
   {
      _keyCode = keyCode;
   }

   /// Ditto
   private int _keyCode = ALLEGRO_KEY_MAX;
}


/// Boilerplate code for input triggers using a joystick.
mixin template JoyMixin()
{
   /// Returns the $(D InputSource) corresponding to $(D _joy).
   private final @property InputSource source()
   {
      return cast(InputSource)(InputSource.JOY0 << _joy);
   }

   /// Is this trigger watching a given Allegro joystick?
   private final bool isSameJoy(const ALLEGRO_JOYSTICK* allegroJoy)
   {
      return InputManager.joyID(allegroJoy) == _joy;
   }

   /**
    * The joystick this trigger is watching.
    *
    * A value of $(D -1) means "invalid joystick".
    */
   public final @property int joy() inout
   {
      return _joy;
   }

   /// Ditto
   public final @property void joy(int joy)
   {
      _joy = joy;
   }

   /// Ditto
   private int _joy = -1;
}


/**
 * Boilerplate code for input triggers using a joystick axis.
 *
 * Assumes $(D JoyMixin) is also mixed whenever it is mixed.
 */
mixin template JoyAxisMixin()
{
   /// Is this trigger watching a given Allegro stick/axis pair?
   private final bool isSameAxis(int stick, int axis)
   {
      return InputManager.joyAxisID(joy, stick, axis) == joyAxis;
   }

   /**
    * The joystick axis this trigger is watching; this is a FewDee-style
    * "sequential ID", not the Allegro-style "stick plus axis" scheme.
    *
    * A value of $(D -1) means "invalid joystick".
    */
   public final @property int joyAxis() inout
   {
      return _joyAxis;
   }

   /// Ditto
   public final @property void joyAxis(int axis)
   {
      _joyAxis = axis;
   }

   /// Ditto
   private int _joyAxis = -1;
}


/// Boilerplate code for input triggers using a joystick button.
mixin template JoyButtonMixin()
{
   /// Is this trigger watching a given Allegro button?
   private final bool isSameJoyButton(int button)
   {
      return _joyButton == button;
   }

   /**
    * The joystick button this trigger is watching.
    *
    * $(D -1) means "invalid button".
    */
   public final @property int joyButton() inout
   {
      return _joyButton;
   }

   /// Ditto
   public final @property void joyButton(int button)
   {
      _joyButton = button;
   }

   /// Ditto
   private int _joyButton = -1;
}


mixin template ThresholdMixin(float initValue)
{
   /// The threshold that must be crossed to trigger.
   public final @property float threshold() inout
   {
      return _threshold;
   }

   /// Ditto
   public final @property void threshold(float threshold)
   {
      _threshold = threshold;
   }

   /// Ditto
   private float _threshold = initValue;
}



//
// Keyboard-based input triggers
//

/// An input trigger that triggers when a certain keyboard key is pressed.
class KeyDownTrigger: InputTrigger
{
   mixin KeyCodeMixin;

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
      this.keyCode = keyCode;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_DOWN
          && isSameKeyCode(event.keyboard.keycode))
      {
         param.source = InputSource.KEYBOARD;
         return true;
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["keyCode"] = keyCodeToString(keyCode);

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasString("keyCode"));
      enforce(state["class"] == className);
      keyCode = stringToKeyCode(state["keyCode"].asString);
   }
}



/// An input trigger that triggers when a certain keyboard key is released.
class KeyUpTrigger: InputTrigger
{
   mixin KeyCodeMixin;

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
      this.keyCode = keyCode;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_KEY_UP
          && isSameKeyCode(event.keyboard.keycode))
      {
         param.source = InputSource.KEYBOARD;
         return true;
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["keyCode"] = keyCodeToString(keyCode);

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasString("keyCode"));
      enforce(state["class"] == className);
      keyCode = stringToKeyCode(state["keyCode"].asString);
   }
}



//
// Joystick-based input triggers
//

/// An input trigger that triggers when a certain joystick button is pressed.
class JoyButtonDownTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyButtonMixin;

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
    *    joy = The joystick to listen to.
    *    button = The button to listen to.
    */
   public this(int joy, int button)
   {
      this.joy = joy;
      this.joyButton = button;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN
          && isSameJoy(event.joystick.id)
          && isSameJoyButton(event.joystick.button))
      {
         param.source = source;
         return true;
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyButton"] = joyButton;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyButton"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyButton = to!int(state["joyButton"].asNumber);
   }
}


/// An input trigger that triggers when a certain joystick button is released.
class JoyButtonUpTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyButtonMixin;

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
    *    joy = The joystick to listen to.
    *    button = The button to listen to.
    */
   public this(int joy, int button)
   {
      this.joy = joy;
      this.joyButton = button;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_UP
          && isSameJoy(event.joystick.id)
          && isSameJoyButton(event.joystick.button))
      {
         param.source = source;
         return true;
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyButton"] = joyButton;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyButton"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyButton = to!int(state["joyButton"].asNumber);
   }
}


/**
 * An input trigger that triggers when a certain joystick axis goes beyond a
 * certain threshold in the positive direction.
 *
 * Think of this is a "key down" event, but for a joystick axis.
 */
class JoyPosAxisDownTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyAxisMixin;
   mixin ThresholdMixin!0.5;

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
    *    joy = The desired joystick.
    *    axis = The desired axis.
    *    threshold = The threshold that must be crossed to trigger.
    */
   public this(int joy, int axis, float threshold = 0.5)
   {
      this.joy = joy;
      this.joyAxis = axis;
      this.threshold = threshold;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && isSameJoy(event.joystick.id)
          && isSameAxis(event.joystick.stick, event.joystick.axis))
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue <= threshold && currValue > threshold)
         {
            param.source = source;
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyAxis"] = joyAxis;
      c["threshold"] = threshold;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyAxis"));
      enforce(state.hasNumber("threshold"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyAxis = to!int(state["joyAxis"].asNumber);
      threshold = state["threshold"].asNumber;
   }

   /// The axis value the last time $(D didTrigger()) was called.
   private float _prevValue = 0.0;
}


/**
 * An input trigger that triggers when a certain joystick axis comes back from a
 * certain threshold in the positive direction.
 *
 * Think of this is a "key up" event, but for a joystick axis.
 */
class JoyPosAxisUpTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyAxisMixin;
   mixin ThresholdMixin!0.5;

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
    *    joy = The desired joystick.
    *    axis = The desired axis.
    *    threshold = The threshold that must be crossed to trigger.
    */
   public this(int joy, int axis, float threshold = 0.5)
   {
      this.joy = joy;
      this.joyAxis = axis;
      this.threshold = threshold;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && isSameJoy(event.joystick.id)
          && isSameAxis(event.joystick.stick, event.joystick.axis))
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue > threshold && currValue <= threshold)
         {
            param.source = source;
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyAxis"] = joyAxis;
      c["threshold"] = threshold;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyAxis"));
      enforce(state.hasNumber("threshold"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyAxis = to!int(state["joyAxis"].asNumber);
      threshold = state["threshold"].asNumber;
   }

   /// The axis value the last time $(D didTrigger()) was called.
   private float _prevValue = 0.0;
}


/**
 * An input trigger that triggers when a certain joystick axis goes beyond a
 * certain threshold in the negative direction.
 *
 * Think of this is a "key down" event, but for a joystick axis.
 */
class JoyNegAxisDownTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyAxisMixin;
   mixin ThresholdMixin!(-0.5);

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
    *    joy = The desired joystick.
    *    axis = The desired axis.
    *    threshold = The threshold that must be crossed to trigger.
    */
   public this(int joy, int axis, float threshold = -0.5)
   {
      this.joy = joy;
      this.joyAxis = axis;
      this.threshold = threshold;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && isSameJoy(event.joystick.id)
          && isSameAxis(event.joystick.stick, event.joystick.axis))
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue >= threshold && currValue < threshold)
         {
            param.source = source;
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyAxis"] = joyAxis;
      c["threshold"] = threshold;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyAxis"));
      enforce(state.hasNumber("threshold"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyAxis = to!int(state["joyAxis"].asNumber);
      threshold = state["threshold"].asNumber;
   }

   /// The axis value the last time $(D didTrigger()) was called.
   private float _prevValue = 0.0;
}


/**
 * An input trigger that triggers when a certain joystick axis comes back from a
 * certain threshold in the negative direction.
 *
 * Think of this is a "key up" event, but for a joystick axis.
 */
class JoyNegAxisUpTrigger: InputTrigger
{
   mixin JoyMixin;
   mixin JoyAxisMixin;
   mixin ThresholdMixin!(-0.5);

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
    *    joy = The desired joystick.
    *    axis = The desired axis.
    *    threshold = The threshold that must be crossed to trigger.
    */
   public this(int joy, int axis, float threshold = -0.5)
   {
      this.joy = joy;
      this.joyAxis = axis;
      this.threshold = threshold;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS
          && isSameJoy(event.joystick.id)
          && isSameAxis(event.joystick.stick, event.joystick.axis))
      {
         const currValue = event.joystick.pos;
         const prevValue = _prevValue;
         _prevValue = currValue;

         if (prevValue < threshold && currValue >= threshold)
         {
            param.source = source;
            return true;
         }
      }

      return false;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["joy"] = joy;
      c["joyAxis"] = joyAxis;
      c["threshold"] = threshold;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasNumber("joy"));
      enforce(state.hasNumber("joyAxis"));
      enforce(state.hasNumber("threshold"));
      enforce(state["class"] == className);
      joy = to!int(state["joy"].asNumber);
      joyAxis = to!int(state["joyAxis"].asNumber);
      threshold = state["threshold"].asNumber;
   }

   /// The axis value the last time $(D didTrigger()) was called.
   private float _prevValue = 0.0;
}
