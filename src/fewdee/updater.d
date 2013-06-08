/**
 * A fire-and-forget mechanism to run functions that update things.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.updater;

import allegro5.allegro;
import std.conv;
import fewdee.event;
import fewdee.low_level_event_handler;


/**
 * A fire-and-forget mechanism to run functions that update things. Originally
 * thought as a simple way to run shortish animations, but can in fact be used
 * to do anything.
 */
public class Updater: LowLevelEventHandler
{
   /**
    * A function callable by an Updater. It must return true if it wants to be
    * called again or false if doesn't want to. And it receives as parameter the
    * amount of time (in seconds) by which the function must update whatever it
    * is updating.
    *
    * Notice that this "function" is actually a delegate, so that it can have
    * its own state (closures for the win!).
    */
   public alias bool delegate(double deltaTime) func_t;

   /**
    * When getting a tick event, calls all updater functions and remove the ones
    * that don't want to be called anymore.
    */
   public override void handleEvent(in ref ALLEGRO_EVENT event)
   {
      if (event.type != FEWDEE_EVENT_TICK)
         return;

      immutable deltaTime = event.user.deltaTime;

      func_t[] toRemove;

      foreach(func, dummy; funcs_)
      {
         if (!func(deltaTime))
            toRemove ~= func;
      }

      foreach(func; toRemove)
         funcs_.remove(func);
   }

   /// Adds an updater function to the Updater.
   void add(func_t func)
   {
      funcs_[func] = true;
   }

   /// The active updater functions.
   private int[func_t] funcs_;
}
