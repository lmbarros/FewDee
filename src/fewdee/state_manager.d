/**
 * FewDee's State Manager.
 *
 * This implements a tried and true idiom: a stack of states in which, normally,
 * only the state on top (that is, the current one) responds to events.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.state_manager;

import std.typecons;
import allegro5.allegro;
import fewdee.event;
import fewdee.event_manager;
import fewdee.game_state;
import fewdee.low_level_event_handler;
import fewdee.internal.singleton;


/**
 * The real implementation of the State Manager. Users shall use this through
 * the $(D StateManager) class.
 *
 * Manages a stack of states and provides the necessary methods to handle it.
 *
 * The $(D StateManager) owns the states it manages. It will call $(D destroy())
 * on these states as appropriate. This means that keeping external references
 * to these states is a bad idea, since they may end up pointing to invalid
 * (destroyed) states.
 */
private class StateManagerImpl: LowLevelEventHandler
{
   /**
    * Destroys the State Manager. Ensures that the destructors of all remaining
    * game states (if any) are called.
    */
   public ~this()
   {
      foreach(state; _states)
         destroy(state);
   }

   /// Returns the state at the top of the stack (AKA the current state).
   public final @property GameState top()
   in
   {
      assert(_states.length > 0);
   }
   body
   {
      return _states[$-1];
   }

   /// Checks whether the stack of states is empty.
   public final @property bool empty() const { return _states.length == 0; }

   /// Pushes a state into the stack of Game States.
   public final void pushState(GameState state)
   {
      import std.stdio; writefln("StateManager: pushing '%s'", state);

      // xxxxxxxxxxxxxxxxxxx
      // Allow just one push or pop per tick
      if (_statePopped || _statePushed)
         return;

      if (_states.length > 0)
         _states[$-1].onBury();

      _states ~= state;

      _statePushed = state;

      import std.stdio; writefln("StateManager: pushed '%s'", state);
   }

   /**
    * Pops the state on the top of the stack of Game States. The destructor of
    * the popped state is called.
    */
   public final void popState()
   in
   {
      assert(_states.length > 0);
   }
   body
   {
      import std.stdio; writefln("StateManager: popping '%s'; size was %s.",
                                 _states[$-1], _states.length);

      // xxxxxxxxxxxxxxxxxxx
      // Allow just one push or pop per tick
      if (_statePopped || _statePushed)
         return;

      removeAllStateHandlers(_states[$-1]);
      destroy(_states[$-1]); // ensure that destructor is called

      import std.stdio; writefln("11111111");
      _states = _states[0 .. $-1];

      import std.stdio; writefln("2222222");
      if (_states.length > 0)
      {
         import std.stdio; writefln("3aaaaa");
         _states[$-1].onDigOut();
      }
      else
         import std.stdio; writefln("3bbbbb");

      _statePopped = true;

      import std.stdio; writefln("StateManager: popped, new top is '%s'; new size is %s.",
                                 _states.length > 0 ? _states[$-1] : null, _states.length);
   }

   /**
    * Replaces the state in the top of the stack of Game States with a new
    * one. $(D onDigOut()) and $(D onBury()) are not called.  The destructor of
    * the replaced state is called.
    */
   public final void replaceState(GameState state)
   in
   {
      assert(_states.length > 0);
   }
   body
   {
      import std.stdio; writefln("StateManager: replacing '%s' with '%s'; size was %s.",
                                 _states[$-1], state, _states.length);

      // xxxxxxxxxxxxxxxxxxx
      // Allow just one push or pop per tick
      if (_statePopped || _statePushed)
         return;

      removeAllStateHandlers(_states[$-1]);
      destroy(_states[$-1]); // ensure that destructor is called
      _states[$-1] = state;

      _statePushed = state;
      _statePopped = true;

      import std.stdio; writefln("StateManager: replaced ; size now is %s.",
                                 _states.length);
   }

   /**
    * Called when an event (any event) is received. This method then calls the
    * event handlers for the states that want to have their event handlers
    * called.
    *
    * Parameters:
    *    event = The event received.
    */
   public final override bool handleEvent(in ref ALLEGRO_EVENT event)
   {
      // xxxxxxxxxxxxxxx
      // stop handling this tick's events if a state is popped
      if (_statePopped)
         return false;

      foreach (key, handlers; _eventHandlers)
      {
         const keyType = key[1];

         if (keyType != event.type)
            continue;

         const keyState = key[0];

         foreach (handler; _eventHandlers[key])
         {
            immutable wants = event.type == FEWDEE_EVENT_DRAW
               ? keyState.wantsToDraw
               : (event.type == FEWDEE_EVENT_TICK
                  ? keyState.wantsTicks
                  : keyState.wantsEvents);

            // xxxxxxxxxxxxxxxxxxxxxxxxxxx
            // don't handle events of a newly pushed state; wait for next tick
            if (wants && keyState !is _statePushed)
               handler(event);

            // stop handling this tick's events if a state is popped
            if (_statePopped)
               return false;
         }
      }

      return true;
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // start of new code
   public override void emptiedEventQueue()
   {
      _statePopped = false;
      _statePushed = null;
   }

   private bool _statePopped = false;

   // Don't think this is necessary. Would be used to enforce the policy of "if
   // a new state is pushed, it will not get any of its event handlers called in
   // this tick". But if the state was just added, it will not have events in
   // the queue, will it? Hmmm, perhaps it will... how are events added to the
   // queue? Asynchronously, I guess... they can get there anytime.
   //
   // But then... the concept of "tick" (from this event queue point of view) is
   // a bit vague... I simply handle events until the queue is empty. Perhaps
   // this legitimates the call of event handlers from a newly pushed state.
   private GameState _statePushed = null;

   // end of new code
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



   /**
    * Adds an event handler. From this point on, whenever an event of the
    * requested type is triggered, the handler will be called.
    *
    * TODO, doc: If you are using the $(D StateManager), you may wish to
    *       use... (because then the handler will be called only when the state
    *       is active. IOW, this global, not per state.)
    *
    * Parameters:
    *    state = The $(D GameState) registering the handler.
    *    eventType = The type of event to handle.
    *    handler = The handler function.
    *
    * Return:
    *    An ID that can be passed to $(D removeHandler()) if one desires to
    *    remove the event handler later.
    */
   package final EventHandlerID addHandler(
      in GameState state, ALLEGRO_EVENT_TYPE eventType, EventHandler handler)
   {
      auto key = tuple(state, eventType);

      if (key !in _eventHandlers)
         _eventHandlers[key] = typeof(_eventHandlers[key]).init;

      assert(_nextEventHandlerID !in _eventHandlers[key]);

      _eventHandlers[key][_nextEventHandlerID] = handler;

      return _nextEventHandlerID++;
   }

   /**
    * Removes an event handler. If the requested handler wasn't previously added
    * to the Event Manager, nothing happens.
    *
    * Parameters:
    *    id = The ID of the event handler to remove.
    *
    * Return:
    *    $(D true) if the event handler was removed; $(D false) otherwise.
    */
   package final bool removeHandler(EventHandlerID id)
   {
      foreach (key, list; _eventHandlers)
      {
         if (id in _eventHandlers[key])
         {
            _eventHandlers[key].remove(id);
            return true;
         }
      }

      return false; // ID not found
   }

   /**
    * Removes all event handlers associated with a given state.
    *
    * Parameters:
    *    state = The state whose events handlers will be removed.
    */
   private final void removeAllStateHandlers(in GameState state)
   {
      import std.stdio; writefln("StateManager: removing handlers of '%s'", state);

      stateTypePair[] toRemove;

      foreach (key, handlers; _eventHandlers)
      {
         const keyState = key[0];
         if (state is keyState)
            toRemove ~= key;
      }

      foreach (key; toRemove)
      {
         import std.stdio; writefln("   StateManager: removing handler '%s'", key);
         _eventHandlers.remove(key);
      }

      import std.stdio; writefln("StateManager: removed handlers of '%s'", state);
   }

   /// A pair of a $(D GameState) and an event type.
   private alias Tuple!(const(GameState), ALLEGRO_EVENT_TYPE) stateTypePair;

   /**
    * The collection of all registered event handlers.
    *
    * This is an associative array indexed by a pair (game state, event
    * type). Each value in this associative array is itself another associative
    * array, which maps the event handler handle to the event handler itself.
    */
   private EventHandler[EventHandlerID][stateTypePair] _eventHandlers;

   /**
    * The next event handler ID to use. The same sequence of IDs is used for all
    * event types.
    */
   private size_t _nextEventHandlerID = 0;

   /// An array of Game States, used as a stack.
   private GameState[] _states;
}



/**
 * The State Manager singleton. Provides access to the one and only $(D
 * StateManagerImpl) instance.
 */
public class StateManager
{
   mixin LowLockSingleton!StateManagerImpl;
}
