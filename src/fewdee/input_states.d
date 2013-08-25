/**
 * A collection of ready-to-use $(D InputState)s.
 *
 * TODO: There is quite a bit of code replication here. Triggers for handling
 *    key/button up/down events, in particular, are very similar to each
 *    other. Making _triggerKeys a private property would also allow to add a
 *    deserializeTriggers() method.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_states;

import std.exception;
import allegro5.allegro;
import fewdee.config;
import fewdee.input_manager;
import fewdee.input_triggers;



/**
 * A state that be either true or false, as the name suggests.
 */
class BooleanInputState: InputState
{
   // Inherit docs.
   public override void update(in ref ALLEGRO_EVENT event)
   {
      InputHandlerParam param;

      if (didTrigger("setTrue", event, param))
         _value = true;

      if (didTrigger("setFalse", event, param))
         _value = false;

      if (didTrigger("toggle", event, param))
         _value = !_value;
   }

   /// Returns the state value.
   final public @property bool value()
   {
      return _value;
   }

   /**
    * The default state value.
    *
    * Setting it, also sets the current state value.
    */
   final public @property void defaultDalue(bool value)
   {
      _defaultValue = value;
      _value = value;
   }

   /// Ditto.
   final public @property bool defaultDalue()
   {
      return _defaultValue;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;
      c["defaultValue"] = _defaultValue;

      foreach(key; _triggerKeys)
         c[key] = serializeTriggers(key);

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxx TODO: Check if the expected fields are all there. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      clearTriggers();

      _defaultValue = state["defaultValue"].asBoolean;

      foreach (key; _triggerKeys)
      {
         foreach (cfgTrigger; state[key].asList)
         {
            auto objTrigger =
               cast(InputTrigger)(Object.factory(cfgTrigger["class"].asString));

            enforce(objTrigger !is null);

            objTrigger.memento = cfgTrigger;
            addTrigger(key, objTrigger);
         }
      }
   }

   /**
    * Adds an $(D InputTrigger) that, when triggered, sets the state to $(D
    * true).
    */
   public final TriggerID addSetTrueTrigger(InputTrigger trigger)
   {
      return addTrigger("setTrue", trigger);
   }

   /**
    * Adds an $(D InputTrigger) that, when triggered, sets the state to $(D
    * false).
    */
   public final TriggerID addSetFalseTrigger(InputTrigger trigger)
   {
      return addTrigger("setFalse", trigger);
   }

   /// Adds an $(D InputTrigger) that, when triggered, toggles state.
   public final TriggerID addToggleTrigger(InputTrigger trigger)
   {
      return addTrigger("toggle", trigger);
   }

   /**
    * Configures the state for a common case: toggling the state while a given
    * key is kept pressed.
    *
    * Parameters:
    *    keyCode = The key to use.
    *
    * Returns:
    *    An array with all the IDs of all triggers added to this state. This can
    *    be passed to $(D removeTriggers()) in order to remove these triggers.
    */
   public final TriggerID[] useToggleWhileKeyPressed(int keyCode)
   {
      auto t1 = addToggleTrigger(new KeyDownTrigger(keyCode));
      auto t2 = addToggleTrigger(new KeyUpTrigger(keyCode));

      return [ t1, t2 ];
   }

   /**
    * Configures the state for a common case: toggling the state while a given
    * joystick button is kept pressed.
    *
    * Parameters:
    *    joy = The joystick to use.
    *    button = The button to use.
    *
    * Returns:
    *    An array with all the IDs of all triggers added to this state. This can
    *    be passed to $(D removeTriggers()) in order to remove these triggers.
    */
   public final TriggerID[] useToggleWhileJoyButtonPressed(int joy, int button)
   {
      auto t1 = addToggleTrigger(new JoyButtonDownTrigger(joy, button));
      auto t2 = addToggleTrigger(new JoyButtonUpTrigger(joy, button));

      return [ t1, t2 ];
   }

   /**
    * Configures the state for a common case: one key sets state to $(D true),
    * other key sets to $(D false).
    *
    * Parameters:
    *    trueKeyCode = The key that sets the state to $(D true).
    *    falseKeyCode = The key that sets the state to $(D false).
    *
    * Returns:
    *    An array with all the IDs of all triggers added to this state. This can
    *    be passed to $(D removeTriggers()) in order to remove these triggers.
    */
   public final TriggerID[] useKeys(int trueKeyCode, int falseKeyCode)
   {
      auto t1 = addSetTrueTrigger(new KeyDownTrigger(trueKeyCode));
      auto t2 = addSetFalseTrigger(new KeyDownTrigger(falseKeyCode));

      return [ t1, t2 ];
   }

   /**
    * Configures the state for a common case: toggling the state with a given
    * key press.
    *
    * Parameters:
    *    keyCode = The key to use.
    *
    * Returns:
    *    The IDs of the trigger added to this state. This can be passed to $(D
    *    removeTrigger()) in order to remove it.
    */
   public final TriggerID useToggleWithKeyPress(int keyCode)
   {
      return addToggleTrigger(new KeyDownTrigger(keyCode));
   }

   /**
    * Configures the state for a common case: toggling the state with a given
    * joystick button press.
    *
    * Parameters:
    *    joy = The joystick to use.
    *    button = The button to use.
    *
    * Returns:
    *    The IDs of the trigger added to this state. This can be passed to $(D
    *    removeTrigger()) in order to remove it.
    */
   public final TriggerID useToggleWithJoyButtonPress(int joy, int button)
   {
      return addToggleTrigger(new JoyButtonDownTrigger(joy, button));
   }

   /// The keys of the triggers used by this state.
   private static immutable _triggerKeys = [
      "setTrue", "setFalse", "triggers" ];

   /// The default state value.
   private bool _defaultValue = false;

   /// The state value.
   private bool _value = false;
}


/// The directions a $(D DirectionInputState) can be in.
public enum StateDir
{
   NONE, /// No direction; could be interpreted as "centered" or "neutral".
   N,    /// North (up).
   NE,   /// Northeast (up-right)
   E,    /// East (right)
   SE,   /// Southeast (down-right)
   S,    /// South (down)
   SW,   /// Southwest (down-left)
   W,    /// West (left)
   NW    /// Northwest (up-left)
}

/**
 * A state representing an eight-way directional control; this is usually mapped
 * to the keyboard arrow keys or a joystick D-pad.
 */
class DirectionInputState: InputState
{
   // Inherit docs.
   public override void update(in ref ALLEGRO_EVENT event)
   {
      InputHandlerParam param;

      if (didTrigger("startNorth", event, param)) _n = true;
      if (didTrigger("startSouth", event, param)) _s = true;
      if (didTrigger("startEast", event, param)) _e = true;
      if (didTrigger("startWest", event, param)) _w = true;

      if (didTrigger("stopNorth", event, param)) _n = false;
      if (didTrigger("stopSouth", event, param)) _s = false;
      if (didTrigger("stopEast", event, param)) _e = false;
      if (didTrigger("stopWest", event, param)) _w = false;

      if (_n)
      {
         if (_e)
            _direction = StateDir.NE;
         else if (_w)
            _direction = StateDir.NW;
         else
            _direction = StateDir.N;
      }
      else if (_s)
      {
         if (_e)
            _direction = StateDir.SE;
         else if (_w)
            _direction = StateDir.SW;
         else
            _direction = StateDir.S;
      }
      else if (_e)
      {
         _direction = StateDir.E;
      }
      else if (_w)
      {
         _direction = StateDir.W;
      }
      else
      {
         _direction = StateDir.NONE;
      }
   }

   /**
    * The current direction.
    *
    * Most of the time, this is what you are looking for.
    */
   final public @property StateDir direction() inout
   {
      return _direction;
   }

   // Inherit docs.
   public override @property ConfigValue memento() inout
   {
      ConfigValue c;
      c.makeAA();
      c["class"] = className;

      foreach(key; _triggerKeys)
         c[key] = serializeTriggers(key);

      return c;
   }

   // Inherit docs.
   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxx TODO: Check if the expected fields are all there. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      clearTriggers();

      foreach (key; _triggerKeys)
      {
         foreach (cfgTrigger; state[key].asList)
         {
            auto objTrigger =
               cast(InputTrigger)(Object.factory(cfgTrigger["class"].asString));

            enforce(objTrigger !is null);

            objTrigger.memento = cfgTrigger;
            addTrigger(key, objTrigger);
         }
      }
   }

   /**
    * Configures the state for a common case: using set of four keyboard keys to
    * control the direction.
    *
    * By default, the keys used are the keyboard arrow keys.
    *
    * Parameters:
    *    northKeyCode = The key code of the key used to move north (up).
    *    southKeyCode = The key code of the key used to move south (down).
    *    eastKeyCode = The key code of the key used to move east (right).
    *    westKeyCode = The key code of the key used to move west (left).
    *
    * Returns:
    *    An array with all the IDs of all triggers added to this state. This can
    *    be passed to $(D removeTriggers()) in order to remove these triggers.
    */
   public final TriggerID[] useKeyTriggers(
      int northKeyCode = ALLEGRO_KEY_UP, int southKeyCode = ALLEGRO_KEY_DOWN,
      int eastKeyCode = ALLEGRO_KEY_RIGHT, int westKeyCode = ALLEGRO_KEY_LEFT)
   {
      auto t1 = addStartNorthTrigger(new KeyDownTrigger(northKeyCode));
      auto t2 = addStopNorthTrigger(new KeyUpTrigger(northKeyCode));

      auto t3 = addStartSouthTrigger(new KeyDownTrigger(southKeyCode));
      auto t4 = addStopSouthTrigger(new KeyUpTrigger(southKeyCode));

      auto t5 = addStartEastTrigger(new KeyDownTrigger(eastKeyCode));
      auto t6 = addStopEastTrigger(new KeyUpTrigger(eastKeyCode));

      auto t7 = addStartWestTrigger(new KeyDownTrigger(westKeyCode));
      auto t8 = addStopWestTrigger(new KeyUpTrigger(westKeyCode));

      return [ t1, t2, t3, t4, t5, t6, t7, t8 ];
   }

   /**
    * Configures the state for a common case: using joystick axes to control the
    * direction.
    *
    * By default, the first and second joystick axes are used as the horizontal
    * and vertical axes, respectively.
    *
    * Parameters:
    *    joy = The joystick to use.
    *    xAxis = The axis to be used as the horizontal axis.
    *    yAxis = The axis to be used as the vertical axis.
    *    invertX = Invert the horizontal axis?
    *    invertY = Invert the vertical axis?
    *    threshold = The axis value threshold that must be crossed to trigger a
    *       directional control.
    *
    * Returns:
    *    An array with all the IDs of all triggers added to this state. This can
    *    be passed to $(D removeTriggers()) in order to remove these triggers.
    */
   public final TriggerID[] useJoyAxesTriggers(
      int joy, int xAxis = 0, int yAxis = 1,
      bool invertX = false, bool invertY = false, float threshold = 0.5)
   in
   {
      assert (threshold > 0.0);
   }
   body
   {
      auto t1 = addStartNorthTrigger(
         invertY
         ? new JoyPosAxisDownTrigger(joy, yAxis, threshold)
         : new JoyNegAxisDownTrigger(joy, yAxis, -threshold));

      auto t2 = addStopNorthTrigger(
         invertY
         ? new JoyPosAxisUpTrigger(joy, yAxis, threshold)
         : new JoyNegAxisUpTrigger(joy, yAxis, -threshold));

      auto t3 = addStartSouthTrigger(
         invertY
         ? new JoyNegAxisDownTrigger(joy, yAxis, -threshold)
         : new JoyPosAxisDownTrigger(joy, yAxis, threshold));

      auto t4 = addStopSouthTrigger(
         invertY
         ? new JoyNegAxisUpTrigger(joy, yAxis, -threshold)
         : new JoyPosAxisUpTrigger(joy, yAxis, threshold));

      auto t5 = addStartEastTrigger(
         invertX
         ? new JoyNegAxisDownTrigger(joy, xAxis, -threshold)
         : new JoyPosAxisDownTrigger(joy, xAxis, threshold));

      auto t6 = addStopEastTrigger(
         invertX
         ? new JoyNegAxisUpTrigger(joy, xAxis, -threshold)
         : new JoyPosAxisUpTrigger(joy, xAxis, threshold));

      auto t7 = addStartWestTrigger(
         invertX
         ? new JoyPosAxisDownTrigger(joy, xAxis, threshold)
         : new JoyNegAxisDownTrigger(joy, xAxis, -threshold));

      auto t8 = addStopWestTrigger(
         invertX
         ? new JoyPosAxisUpTrigger(joy, xAxis, threshold)
         : new JoyNegAxisUpTrigger(joy, xAxis, -threshold));

      return [ t1, t2, t3, t4, t5, t6, t7, t8 ];
   }

   /**
    * Adds a trigger that indicates that a certain movement started or finished.
    *
    * Parameters:
    *    trigger: The trigger to add.
    *
    * Returns:
    *    The ID that can be used to remove this trigger.
    */
   public final TriggerID addStartNorthTrigger(InputTrigger trigger)
   {
      return addTrigger("startNorth", trigger);
   }

   /// Ditto.
   public final TriggerID addStartSouthTrigger(InputTrigger trigger)
   {
      return addTrigger("startSouth", trigger);
   }

   /// Ditto.
   public final TriggerID addStartEastTrigger(InputTrigger trigger)
   {
      return addTrigger("startEast", trigger);
   }

   /// Ditto.
   public final TriggerID addStartWestTrigger(InputTrigger trigger)
   {
      return addTrigger("startWest", trigger);
   }

   /// Ditto.
   public final TriggerID addStopNorthTrigger(InputTrigger trigger)
   {
      return addTrigger("stopNorth", trigger);
   }

   /// Ditto.
   public final TriggerID addStopSouthTrigger(InputTrigger trigger)
   {
      return addTrigger("stopSouth", trigger);
   }

   /// Ditto.
   public final TriggerID addStopEastTrigger(InputTrigger trigger)
   {
      return addTrigger("stopEast", trigger);
   }

   /// Ditto.
   public final TriggerID addStopWestTrigger(InputTrigger trigger)
   {
      return addTrigger("stopWest", trigger);
   }

   /// The keys of the triggers used by this state.
   private static immutable _triggerKeys = [
      "startNorth", "startSouth", "startEast", "startWest",
      "stopNorth", "stopSouth", "stopEast", "stopWest" ];

   /// Are we moving northward?
   private bool _n = false;

   /// Are we moving southward?
   private bool _s = false;

   /// Are we moving eastward?
   private bool _e = false;

   /// Are we moving westward?
   private bool _w = false;

   /// The current direction.
   private StateDir _direction = StateDir.NONE;
}
