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
 * This the internal-only interface defining how must a low-level event handler
 * look like.
 *
 * End users wanting to implement a low-level event handler shall use the $(D
 * LowLevelEventHandler) abstract class, which provides automatic registration
 * and de-registration with the $(D EventManager) (which is who forwards events
 * to it).
 */
package interface LowLevelEventHandlerInterface
{
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
   public abstract void beginTick();

   /**
    * This is called when finished to process the events of a tick.
    *
    * TODO: This should be $(D package) instead of $(D public), but D (as of DMD
    *    2.063) doesn't seem to like $(D package) virtual functions.
    */
   public abstract void endTick();
}


/**
 * Provides a default constructor and a destructor which automatically register
 * and de-register the event handler with the $(D EventManager).
 */
package mixin template LowLevelEventHandlerAutoRegister()
{
   /**
    * Registers the event handler with the $(D EventManager), which is the
    * ultimate responsible for, well, managing events.
    */
   public this()
   {
      EventManager.addLowLevelEventHandler(this);
   }

   /// De-registers the event handler with the $(D EventManager).
   public ~this()
   {
      EventManager.removeLowLevelEventHandler(this);
   }
}


/**
 * An interface to be implemented by whoever wants to handle events in a
 * lower-than usual level.
 *
 * As long as a $(D LowLevelEventHandler) lives, it will have its $(D
 * handleEvent()) method called for every event triggered.
 */
public abstract class LowLevelEventHandler: LowLevelEventHandlerInterface
{
   // Automatically registers and de-registers with the Event Manager.
   mixin LowLevelEventHandlerAutoRegister;

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
   public override void beginTick() { }

   /**
    * This is called when finished to process the events of a tick.
    *
    * TODO: This should be $(D package) instead of $(D public), but D (as of DMD
    *    2.063) doesn't seem to like $(D package) virtual functions.
    */
   public override void endTick() { }
}
