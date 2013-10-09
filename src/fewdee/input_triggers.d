/**
 * A collection of ready-to-use $(D InputTrigger)s.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
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


//
// Composite input triggers
//

/**
 * An input trigger that, once starts triggering, keeps triggering regularly
 * until a certain condition is met.
 *
 * An example use case: pressing a certain key will generate a "shot" command,
 * and, until the key is released, new "shot" events will be generated every
 * 0.15 second.
 */
class RepeatingTrigger: InputTrigger
{
   /**
    * The default constructor; if you use it, you must set the trigger
    * parameters manually (either via the appropriate properties, or using $(D
    * memento)).
    */
   public this()
   {
      startTrigger = new DummyTrigger();
      stopTrigger = startTrigger;
   }

   /**
    * Constructs the trigger.
    *
    * Parameters:
    *    startTrigger = An input trigger used to detect if this $(D
    *       RepeatingTrigger) shall start to trigger.
    *    stopTrigger = An input trigger used to detect if this $(D
    *       RepeatingTrigger) shall stop to trigger.
    *    repeatInterval = The time, in seconds, to wait between two consecutive
    *       triggerings.
    *    startTriggering = Start the trigger in a "triggering state"? If $(D
    *       true), the trigger will start to trigger periodically as soon as it
    *       is constructed (until $(D stopTrigger) triggers). If $(D false), the
    *       trigger will start triggering only after $(D startTrigger) triggers.
    *
    */
   public this(InputTrigger startTrigger, InputTrigger stopTrigger,
               double repeatInterval, bool startTriggering = false)
   in
   {
      assert(startTrigger !is null);
      assert(stopTrigger !is null);
   }
   body
   {
      this.startTrigger = startTrigger;
      this.stopTrigger = stopTrigger;
      this.repeatInterval = repeatInterval;
      _isTriggering = startTriggering;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      if (_isTriggering)
      {
         if (_stopTrigger.didTrigger(event, param))
         {
            _isTriggering = false;
            return false;
         }
         else // is still triggering
         {
            if (event.any.timestamp >= _timeOfNextTrigger)
            {
               _timeOfNextTrigger += _repeatInterval;
               return true;
            }
            else
            {
               return false;
            }
         }
      }
      else if (!_isTriggering && _startTrigger.didTrigger(event, param))
      {
         _isTriggering = true;
         _timeOfNextTrigger = event.any.timestamp + _repeatInterval;
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
      c["startTrigger"] = startTrigger.memento;
      c["stopTrigger"] = stopTrigger.memento;
      c["repeatInterval"] = repeatInterval;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasAA("startTrigger"));
      enforce(state.hasAA("stopTrigger"));
      enforce(state.hasNumber("repeatInterval"));
      enforce(state["class"] == className);

      startTrigger = makeInputTrigger(state["startTrigger"]);
      stopTrigger = makeInputTrigger(state["stopTrigger"]);
      repeatInterval = state["repeatInterval"].asNumber;
   }

   /// The trigger used to start the sequence of triggerings.
   public final @property inout(InputTrigger) startTrigger() inout
   {
      return _startTrigger;
   }

   /// Ditto
   public final @property void startTrigger(InputTrigger startTrigger)
   {
      _startTrigger = startTrigger;
   }

   /// Ditto
   private InputTrigger _startTrigger = null;

   /// The trigger used to stop the sequence of triggerings.
   public final @property inout(InputTrigger) stopTrigger() inout
   {
      return _stopTrigger;
   }

   /// Ditto
   public final @property void stopTrigger(InputTrigger stopTrigger)
   {
      _stopTrigger = stopTrigger;
   }

   /// Ditto
   private InputTrigger _stopTrigger = null;

   /// The interval, in seconds, between two consecutive, automatic triggerings.
   public final @property double repeatInterval() inout
   {
      return _repeatInterval;
   }

   /// Ditto
   public final @property void repeatInterval(double repeatInterval)
   {
      _repeatInterval = repeatInterval;
   }

   /// Ditto
   private double _repeatInterval;

   /// The time the next triggering will occur.
   private double _timeOfNextTrigger;

   /**
    * Are we in a triggering state?
    *
    * We'll not trigger if this is not $(D true).
    */
   private bool _isTriggering;
}


//
// Miscellaneous input triggers
//

/**
 * An input trigger that never triggers (or always triggers).
 *
 * This is
 */
class DummyTrigger: InputTrigger
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
    *    alwaysTriggers = Shall this trigger always trigger? (If not, it never
    *       triggers.)
    */
   public this(bool alwaysTriggers = false)
   {
      this.alwaysTriggers = alwaysTriggers;
   }

   // Inherit docs.
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      return alwaysTriggers;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["alwaysTriggers"] = alwaysTriggers;

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      enforce(state.hasString("class"));
      enforce(state.hasBoolean("alwaysTriggers"));
      enforce(state["class"] == className);
      alwaysTriggers = state["alwaysTriggers"].asBoolean;
   }

   /**
    * Shall this trigger always trigger?
    *
    * If not, it will never trigger.
    */
   public final @property bool alwaysTriggers() inout
   {
      return _alwaysTriggers;
   }

   /// Ditto
   public final @property void alwaysTriggers(bool alwaysTriggers)
   {
      _alwaysTriggers = alwaysTriggers;
   }

   /// Ditto
   private bool _alwaysTriggers = false;
}
