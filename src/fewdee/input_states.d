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

