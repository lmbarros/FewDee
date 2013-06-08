/**
 * An interface to be implemented by whoever wants to handle events in a
 * lower-than usual level.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.low_level_event_handler;

import allegro5.allegro;
import fewdee.event_manager;


/**
 * An interface to be implemented by whoever wants to handle events in a
 * lower-than usual level.
 *
 * As long as a $(D LowLevelEventHandler) lives, it will have its $(D
 * handleEvent()) method called for every event triggered.
 */
public abstract class LowLevelEventHandler
{
   /**
    * Constructs the $(D LowLevelEventHandler); registers it with the $(D
    * EventManager), which is the ultimate responsible for, well, managing
    * events.
    */
   public this()
   {
      EventManager.addLowLevelEventHandler(this);
   }

   /**
    * Destroys the $(D LowLevelEventHandler); de-registers it with the $(D
    * EventManager).
    */
   public ~this()
   {
      EventManager.removeLowLevelEventHandler(this);
   }

   /**
    * Handles an incoming event.
    *
    * Parameters:
    *    event = The event to handle.
    */
   public abstract void handleEvent(in ref ALLEGRO_EVENT event);

   /**
    * This is called when starting to process the events of a tick.
    *
    * TODO: This should be $(D package) instead of $(D public), but D (as of DMD
    *    2.063) doesn't seem to like $(D package) virtual functions.
    */
   public void beginTick() { }

   /**
    * This is called when finished to process the events of a tick.
    *
    * TODO: This should be $(D package) instead of $(D public), but D (as of DMD
    *    2.063) doesn't seem to like $(D package) virtual functions.
    */
   public void endTick() { }
}
