/**
 * A collection of ready-to-use $(D InputState)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_states;

import allegro5.allegro;
import fewdee.config;
import fewdee.input_manager;
import fewdee.input_triggers;



// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
class BooleanInputState: InputState
{
   final public @property bool value()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return true;
   }

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   }

   // xxxxxxxxxxx and the same for false...
   public final void addTrueTrigger(InputTrigger trigger)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // add to list of triggers
   }

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

   public override @property const(ConfigValue) memento()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
    *    be passed to $(D removeTrigger()) in order to remove these triggers.
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
    *    be passed to $(D removeTrigger()) in order to remove these triggers.
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
