/**
 * Base class for the states the game can be in.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.game_state;

import std.conv;
import allegro5.allegro;
import fewdee.event_manager;
import fewdee.state_manager;


/// Base class for the states the game can be in.
public class GameState
{
   /// Pushes a state on top of this one. onBury() will be called.
   protected final void pushState(GameState state)
   {
      StateManager.pushState(state);
   }

   /// Pops this state from the stack of Game States.
   public final void popState()
   {
      StateManager.popState();
   }

   /**
    * Replaces this state in the top of the stack of Game States with a new
    * one. $(D onDigOut()) and $(D onBury()) are not called.
    */
   public final void replaceState(GameState state)
   {
      StateManager.replaceState(state);
   }

   /**
    * Called when this state is buried under another one (that is, when a new
    * state is pushed into the stack, just on top of this one).
    *
    * The default implementation simply says that this state no longer desires
    * to receive any events.
    */
   public void onBury()
   {
      wantsTicks = false;
      wantsEvents = false;
      wantsToDraw = false;
   };

   /**
    * Called when this state becomes the one on the top of stack again, after
    * the state previously on top was popped.
    *
    * The default implementation simply says that this state desires to restart
    * receiving all events.
    */
   public void onDigOut()
   {
      wantsTicks = true;
      wantsEvents = true;
      wantsToDraw = true;
   };

   /**
    * Adds an event handler. Its handleEvent() method will be called from now on
    * for every event handled by this game state.
    *
    * Parameters:
    *    handler = The event handler to add.
    */
   public final EventHandlerID addHandler(
      ALLEGRO_EVENT_TYPE eventType, EventHandler handler)
   {
      return StateManager.addHandler(this, eventType, handler);
   }

   /**
    * Removes an event handler. If the requested handler wasn't previously
    * added, nothing happens.
    *
    * Parameters:
    *    id = The ID of the event handler to remove.
    *
    * Return:
    *    $(D true) if the event handler was removed; $(D false) otherwise.
    */
   public final bool removeHandler(EventHandlerID id)
   {
      return StateManager.removeHandler(id);
   }

   /// Converts the $(D GameState) to a $(D string).
   public override string toString() const
   {
      return "GameState(" ~ typeid(this).name ~ ")";
   }

   /// Does this GameState want to receive "tick" events?
   public final @property bool wantsTicks() const { return _wantsTicks; }

   /// Does this GameState want to receive "tick" events?
   public final @property void wantsTicks(bool wants) { _wantsTicks = wants; }

   /// Does this GameState want to receive events other than "tick"?
   public final @property bool wantsEvents() const { return _wantsEvents; }

   /// Does this GameState want to receive events other than "tick"?
   public final @property void wantsEvents(bool wants) { _wantsEvents = wants; }

   /// Does this GameState want to draw?
   public final @property bool wantsToDraw() const { return _wantsToDraw; }

   /// Does this GameState want to draw?
   public final @property void wantsToDraw(bool wants) { _wantsToDraw = wants; }

   /// Does this GameState want to receive "tick" events?
   private bool _wantsTicks = true;

   /// Does this GameState want to receive events other than "tick"?
   private bool _wantsEvents = true;

   /// Does this GameState want to draw?
   private bool _wantsToDraw = true;
}
