/**
 * Base class for the states the game can be in.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.game_state;

import allegro5.allegro;
import twodee.event_handler;
import twodee.state_manager;


/// Base class for the states the game can be in.
class GameState
{
   /// Pushes a state on top of this one. onBury() will be called.
   protected void pushState(GameState state)
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.pushState(state);
   }

   /// Pops this state from the stack of Game States.
   public void popState()
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.popState();
   }

   /**
    * Replaces this state in the top of the stack of Game States with a new
    * one. onDigOut() and onBury() are not called.
    */
   public void replaceState(GameState state)
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.replaceState(state);
   }

   /**
    * Called when this state is buried under another one (that is, when a new
    * state is pushed into the stack, just on top of this one).
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
    */
   public void onDigOut()
   {
      wantsTicks = true;
      wantsEvents = true;
      wantsToDraw = true;
   };

   /// Called periodically. This is the place to do all the drawing.
   public void onDraw() { };

   /**
    * Called when an event is received. Calls all event callbacks registered for
    * event.type and forwards the event to the registered event handlers.
    *
    * Parameters:
    *    event = The event received.
    */
   public void onEvent(in ref ALLEGRO_EVENT event)
   {
      auto pCallbacks = event.type in eventCallbacks_;
      if (pCallbacks !is null)
      {
         foreach (callback; *pCallbacks)
            callback(event);
      }

      foreach (eventHandler; eventHandlers_)
         eventHandler.handleEvent(event);
   }


   /**
    * Adds an event handler. Its handleEvent() method will be called from now on
    * for every event handled by this game state.
    *
    * Parameters:
    *    handler = The event handler to add.
    */
   public void addEventHandler(EventHandler handler)
   {
      eventHandlers_ ~= handler;
   }


   /**
    * Adds an event callback for a given type. The callback will be called
    * whenever an event of the requested type arrives. It is OK to add multiple
    * callbacks for the same event type; all of them will be called.
    */
   void addEventCallback(ALLEGRO_EVENT_TYPE type, EventCallback_t callback)
   {
      eventCallbacks_[type] ~= callback;
   }

   /// Does this GameState want to receive "tick" events?
   public @property bool wantsTicks() const { return wantsTicks_; }

   /// Does this GameState want to receive "tick" events?
   public @property wantsTicks(bool wants) { wantsTicks_ = wants; }

   /// Does this GameState want to receive events other than "tick"?
   public @property bool wantsEvents() const { return wantsEvents_; }

   /// Does this GameState want to receive events other than "tick"?
   public @property wantsEvents(bool wants) { wantsEvents_ = wants; }

   /// Does this GameState want to draw?
   public @property bool wantsToDraw() const { return wantsToDraw_; }

   /// Does this GameState want to draw?
   public @property wantsToDraw(bool wants) { wantsToDraw_ = wants; }

   /**
    * The StateManager managing this state. This is set by the StateManager
    * itself, as soon as this is added to it.
    */
   package StateManager stateManager_;

   /// Does this GameState want to receive "tick" events?
   private bool wantsTicks_ = true;

   /// Does this GameState want to receive events other than "tick"?
   private bool wantsEvents_ = true;

   /// Does this GameState want to draw?
   private bool wantsToDraw_ = true;

   /// A type for an event callback.
   protected alias void delegate(in ref ALLEGRO_EVENT event) EventCallback_t;

   /**
    * The registered event callbacks. This is an associative array whose index
    * is the event type, and whose value is an array with the registered
    * callbacks for that type.
    */
   private EventCallback_t[][ALLEGRO_EVENT_TYPE] eventCallbacks_;

   /// The list of objects that want to receive events to handle them.
   private EventHandler[] eventHandlers_;
}
