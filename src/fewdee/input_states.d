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



// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
class DirectionInputState: InputState
{
   // xxxxxx global? (to make client code shorter) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public enum Direction
   {
      NONE, N, NE, E, SE, S, SW, W, NW
   }

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
            _direction = Direction.NE;
         else if (_w)
            _direction = Direction.NW;
         else
            _direction = Direction.N;
      }
      else if (_s)
      {
         if (_e)
            _direction = Direction.SE;
         else if (_w)
            _direction = Direction.SW;
         else
            _direction = Direction.S;
      }
      else if (_e)
      {
         _direction = Direction.E;
      }
      else if (_w)
      {
         _direction = Direction.W;
      }
      else
      {
         _direction = Direction.NONE;
      }
   }

   final public @property Direction direction() inout
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

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // wraps a common use case
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

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // wraps a common use case
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


   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStartNorthTrigger(InputTrigger trigger)
   {
      return addTrigger("startNorth", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStartSouthTrigger(InputTrigger trigger)
   {
      return addTrigger("startSouth", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStartEastTrigger(InputTrigger trigger)
   {
      return addTrigger("startEast", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStartWestTrigger(InputTrigger trigger)
   {
      return addTrigger("startWest", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStopNorthTrigger(InputTrigger trigger)
   {
      return addTrigger("stopNorth", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStopSouthTrigger(InputTrigger trigger)
   {
      return addTrigger("stopSouth", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStopEastTrigger(InputTrigger trigger)
   {
      return addTrigger("stopEast", trigger);
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public final TriggerID addStopWestTrigger(InputTrigger trigger)
   {
      return addTrigger("stopWest", trigger);
   }

   private bool _n = false;
   private bool _s = false;
   private bool _e = false;
   private bool _w = false;
   private Direction _direction = Direction.NONE;
}

