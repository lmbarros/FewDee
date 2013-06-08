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
 *
 * Policies:
 *
 *    An stack of states idiom and an event-handling system based on delegates
 *    interact in some complex ways. For example, suppose that within a very
 *    short period, two different events trigger two different handlers of the
 *    state on the top of the stack. One of the handlers calls $(D pushState()),
 *    the other one calls $(D popState()). What should be done?  One more
 *    example: a sequence of events is generated; one handler for the first
 *    event calls $(D pushState()). Should the newly pushed state's handlers for
 *    them be called? Should the previously-on-top state's handlers be called?
 *
 *    In many cases, a bad decision on what to do in theses cases can lead to
 *    hard-to-debug problems. In other cases, the decision itself is not
 *    critical, but may influence FewDee's users own design decisions. In either
 *    case, it is worthwhile to know how things happen. So, here are the
 *    policies used by the $(D StateManager) to deal with situations like those
 *    mentioned above:
 *
 *    $(UL
 *       $(LI Only the first push/pop/replace state request during a given tick
 *          is executed.
 *
 *          This avoids several problems that would put the stack
 *          in an unexpected state. Suppose the game is in an "in-game"
 *          state. The player dies, and therefore some handler requests to
 *          replace the current state with a "game over" state. But during the
 *          same tick, the player also has pressed the some key that pushes the
 *          "pause menu" state. If both stack requests were executed, the game
 *          would end up in a "pause menu" state (where the player would be able
 *          to, say, equip different weapons), but with a "game over" state
 *          under it, instead of an "in-game" state".
 *
 *          Naturally, this has side-effects. In the same example, if the events
 *          come in the opposite order and only the first (push "pause menu"
 *          state) is handled, you could end up with the player escaping death,
 *          depending on how you implemented health checks. Anyway, it shall be
 *          far easier to handle these side-effects than to deal with all the
 *          different possible ways in which the stack of states could get into
 *          some invalid or unexpected configuration.)
 *
 *       $(LI A popped state stops having its event handlers called as soon as
 *          it is popped.
 *
 *          If a state is removed from the stack, it doesn't make much sense for
 *          it to handle more events.)
 *
 *       $(LI A newly pushed state will start handling events only in the next
 *          tick.)
 *
 *       $(LI A state that becomes the new stack top because the state
 *          previously on top was popped will start handling events only in the
 *          next tick, unless it was already handling events.
 *
 *          Recall that the default behavior of "only the state on the top
 *          handles events" can be overridden. So, if a non-top state was
 *          already handling events, it will not stop to handle them for the
 *          rest of the tick just because it became the new top. On the other
 *          hand, if the state was not handling events, it will start to handle
 *          them just on the next tick.)
 *
 *       $(LI The states' $(D onBury()) and $(D onDigOut()) are called only in
 *          the of the tick.
 *
 *          This is, in fact, just the general rule from which the two previous
 *          cases are derived.)
 *    )
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
      // The first push must do the real pushing at the moment this is called
      // (and not latter, when 'endTick()' is called). The reason is related to
      // the form of a typical main loop:
      //
      //    while (!StateManager.empty) { ... }
      //
      // We need a state in the stack, otherwise we'll not even enter in the
      // loop; but 'EventManager.triggerTickEvent()' is called only when er are
      // already in the loop. An alternative would be to change the
      // implementation of 'empty()' such that if '_pushedState !is null', then
      // the stack is not considered empty. But this would make 'empty()', which
      // is called every loop iteration, a very tiny bit less efficient (for no
      // gain).
      if (_states.length == 0)
      {
         _states ~= state;
         return;
      }

      // Allow just one push or pop per tick. See "Policies" in class' docs.
      if (_poppedState !is null || _pushedState !is null)
         return;

      // Set state so that 'endTick()' can complete the operation later.
      _pushedState = state;
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
      // Allow just one push or pop per tick. See "Policies" in class' docs.
      if (_poppedState !is null || _pushedState !is null)
         return;

      // Set state so that 'endTick()' can complete the operation later.
      _poppedState = _states[$-1];
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
      // Allow just one push or pop per tick. See "Policies" in class' docs.
      if (_poppedState !is null || _pushedState !is null)
         return;

      // Set state so that 'endTick()' can complete the operation later.
      _pushedState = state;
      _poppedState = _states[$-1];
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

            // As per the policies in the class' docs, don't handle events for
            // newly pushed or popped states. States being "dug out" will handle
            // events if wanting to ('_pushedState' will be null in this case)
            if (wants && keyState !is _pushedState && keyState !is _poppedState)
               handler(event);
         }
      }

      return true;
   }

   /**
    * This gets called in the end of every tick. This is the place where pushes
    * and pops are effectively performed.
    */
   public override void endTick()
   {
      if (_poppedState !is null && _pushedState !is null) // replace
      {
         assert(_states.length > 0);
         assert(_poppedState is _states[$-1]);

         removeAllStateHandlers(_states[$-1]);
         destroy(_states[$-1]);
         _states[$-1] = _pushedState;
      }
      else if (_poppedState !is null) // pop
      {
         assert(_states.length > 0);
         assert(_poppedState is _states[$-1]);

         removeAllStateHandlers(_states[$-1]);
         destroy(_states[$-1]);
         _states = _states[0 .. $-1];

         if (_states.length > 0)
            _states[$-1].onDigOut();
      }
      else if (_pushedState !is null) // push
      {
         if (_states.length > 0)
            _states[$-1].onBury();

         _states ~= _pushedState;
      }

      // Tick is over. Clean up internal state for the next tick.
      _poppedState = null;
      _pushedState = null;
   }

   /**
    * The state that was popped (or replaced) during the current tick. Used in
    * the communication between $(D pushState()), $(D popState()), $(D
    * replaceState()) and $(D endTick()). $(D null) if no state was popped
    * during the current tick.
    */
   private GameState _poppedState = null;

   /**
    * The state that was pushed (or replaced another one) during the current
    * tick. Used in the communication between $(D pushState()), $(D popState()),
    * $(D replaceState()) and $(D endTick()). $(D null) if no state was pushed
    * during the current tick.
    */
   private GameState _pushedState = null;

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
    * Returns:
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
    * Returns:
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
      stateTypePair[] toRemove;

      foreach (key, handlers; _eventHandlers)
      {
         const keyState = key[0];
         if (state is keyState)
            toRemove ~= key;
      }

      foreach (key; toRemove)
         _eventHandlers.remove(key);
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
