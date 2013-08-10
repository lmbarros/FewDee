/**
 * A collection of ready-to-use $(D InputTrigger)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_triggers;

import allegro5.allegro;
import fewdee.config;
import fewdee.input_manager;


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
class DummyInputTrigger: InputTrigger
{
   public override bool didTrigger(in ref ALLEGRO_EVENT event,
                                   out InputHandlerParam param)
   {
      return false;
   }

   public override @property const(ConfigValue) memento()
   {
      return ConfigValue();
   }

   public override @property void memento(const ConfigValue state)
   {
      // nothing...
   }
}
