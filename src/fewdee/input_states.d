/**
 * A collection of ready-to-use $(D InputState)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_states;

import allegro5.allegro;
import fewdee.config;
import fewdee.input_manager;



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

