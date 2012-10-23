/**
 * A fire-and-forget mechanism to run functions that update things.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.updater;

import allegro5.allegro;
import std.conv;


/**
 * A fire-and-forget mechanism to run functions that update things. Originally
 * thought as a simple way to run shortish animations, but can in fact be used
 * to do anything.
 */
class Updater
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
    * Calls all updater functions and remove the ones that don't want to be
    * called anymore. This must be called by the client.
    */
   public void tick(double deltaT)
   {
      func_t[] toRemove;

      foreach(func, dummy; funcs_)
      {
         if (!func(deltaT))
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
