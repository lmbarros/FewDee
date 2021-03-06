/**
 * FewDee's Event Manager and related definitions.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event_manager;

import std.exception;
import allegro5.allegro;
import fewdee.allegro_manager;
import fewdee.engine;
import fewdee.event;
import fewdee.low_level_event_handler;
import fewdee.internal.singleton;


/**
 * The type of functions (er, delegates) used to handle events.
 *
 * The function receives a single parameter: the event structure describing it
 * in detail.
 */
public alias void delegate(in ref ALLEGRO_EVENT event) EventHandler;


/**
 * An opaque identifier identifying an $(D EventHandler) added to the Event
 * Manager.
 *
 * It can be used to remove the handler from the list of handlers.
 */
public alias size_t EventHandlerID;


/**
 * An $(D EventHandlerID) that is guaranteed to be different to all real $(D
 * EventHandlerID)s. It is safe to pass this value to $(D
 * EventManager.removeHandler()): the function will do nothing.
 */
public immutable EventHandlerID InvalidEventHandlerID = 0;


/**
 * The real implementation of the Event Manager. Users shall use this through
 * the $(D EventManager) class.
 *
 * The Event Manager allows you to do low-level event handling. You may wish to
 * check the $(D InputManager), which provides higher-level features for
 * handling user input.
 *
 * See_also: InputManager
 */
private class EventManagerImpl
{
   /// Constructs the Event Manager.
   private this()
   {
      // Initialize input subsystems. We'll probably want to add Touch Input
      // support with Allegro 5.1.
      if (Engine.requestedFeatures & Features.MOUSE)
         AllegroManager.initMouse();

      if (Engine.requestedFeatures & Features.KEYBOARD)
         AllegroManager.initKeyboard();

      if (Engine.requestedFeatures & Features.JOYSTICK)
         AllegroManager.initJoystick();

      // Initialize the event handling data structures
      al_init_user_event_source(&_customEventSource);
      scope (failure)
         al_destroy_user_event_source(&_customEventSource);

      _eventQueue = al_create_event_queue();
      enforce(_eventQueue);
      scope (failure)
         al_destroy_event_queue(_eventQueue);

      if (Engine.requestedFeatures & Features.MOUSE)
         al_register_event_source(_eventQueue, al_get_mouse_event_source());

      if (Engine.requestedFeatures & Features.KEYBOARD)
         al_register_event_source(_eventQueue, al_get_keyboard_event_source());

      if (Engine.requestedFeatures & Features.JOYSTICK)
         al_register_event_source(_eventQueue, al_get_joystick_event_source());

      al_register_event_source(_eventQueue, &_customEventSource);
   }

   /// Destroys the Event Manager.
   package ~this()
   {
      if (Engine.requestedFeatures & Features.MOUSE)
         al_unregister_event_source(_eventQueue, al_get_mouse_event_source());

      if (Engine.requestedFeatures & Features.KEYBOARD)
         al_unregister_event_source(_eventQueue, al_get_keyboard_event_source());

      if (Engine.requestedFeatures & Features.JOYSTICK)
         al_unregister_event_source(_eventQueue, al_get_joystick_event_source());

      al_unregister_event_source(_eventQueue, &_customEventSource);

      al_destroy_event_queue(_eventQueue);
      al_destroy_user_event_source(&_customEventSource);
   }

   /**
    * Adds an event handler. From this point on, whenever an event of the
    * requested type is triggered, the handler will be called.
    *
    * If you are using the $(D StateManager) (which is probably a good idea!),
    * you may wish to call $(D GameState.addHandler()) instead. This method adds
    * what can be seen as a "global" handler, that will get called regardless of
    * the current game state. $(D GameState.addHandler()) will add a
    * "state-conscious" handler, which will be called only when that state is
    * the current one (or if you explicitly said you wanted that state to
    * receive events even when not on the top of the stack).
    *
    * Parameters:
    *    eventType = The type of event to handle.
    *    handler = The handler function.
    *
    * Returns:
    *    An ID that can be passed to $(D removeHandler()) if one desires to
    *    remove the event handler later.
    */
   public final EventHandlerID addHandler(
      ALLEGRO_EVENT_TYPE eventType, EventHandler handler)
   {
      if (eventType !in _eventHandlers)
         _eventHandlers[eventType] = typeof(_eventHandlers[eventType]).init;

      assert(_nextEventHandlerID !in _eventHandlers[eventType]);

      _eventHandlers[eventType][_nextEventHandlerID] = handler;

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
   public final bool removeHandler(EventHandlerID id)
   {
      foreach (eventType, list; _eventHandlers)
      {
         if (id in _eventHandlers[eventType])
         {
            _eventHandlers[eventType].remove(id);
            return true;
         }
      }

      return false; // ID not found
   }

   /**
    * The collection of all registered event handlers.
    *
    * This is an associative array indexed by the event type. Each value in this
    * associative array is itself another associative array, which maps the
    * event handler handle to the event handler itself.
    */
   private EventHandler[EventHandlerID][ALLEGRO_EVENT_TYPE] _eventHandlers;

   /**
    * The next event handler ID to use. The same sequence of IDs is used for all
    * event types.
    */
   private EventHandlerID _nextEventHandlerID = InvalidEventHandlerID + 1;

   /**
    * Adds a low-level event handler. From this call on, the $(D
    * LowLevelEventHandler) passed as parameter will have its $(D handleEvent())
    * method called for every event triggered.
    */
   package final
   void addLowLevelEventHandler(LowLevelEventHandlerInterface handler)
   {
      _lowLevelEventHandlers[handler] = true;
   }

   /**
    * Removes a low-level event handler. From this call on, the $(D
    * LowLevelEventHandler) passed as parameter will no longer have its $(D
    * handleEvent()) method called.
    */
   package final
   void removeLowLevelEventHandler(LowLevelEventHandlerInterface handler)
   {
      _lowLevelEventHandlers.remove(handler);
   }

   /**
    * The list of low-level event handlers.
    *
    * This is an associative array used as a set (the Boolean value is not used,
    * it is just a formal requirement).
    *
    * TODO: Replace this with a $(D std.container.RedBlackTree) or something
    *       like this?
    */
   private bool[LowLevelEventHandlerInterface] _lowLevelEventHandlers;

   /**
    * Causes a tick event to be generated. This must be called from the main
    * game loop.
    *
    * Ticks are the game logic heartbeats. Tick handlers are the usual places
    * where the game state is updated.
    *
    * Parameters:
    *    deltaT = The wall time, in seconds, elapsed since the last time this
    *       function was called.
    */
   public final void triggerTickEvent(double deltaT)
   {
      // Update tick time, re-sync drawing time with it
      _tickTime += deltaT;
      _drawingTime = _tickTime;

      // Emit a tick event
      ALLEGRO_EVENT tickEvent;
      tickEvent.user.type = FEWDEE_EVENT_TICK;
      tickEvent.user.deltaTime = deltaT;
      tickEvent.user.totalTime = _tickTime;
      al_emit_user_event(&_customEventSource, &tickEvent, null);

      // Call handlers for all pending events (and this includes the tick event
      // we just emitted)
      foreach (handler, dummy; _lowLevelEventHandlers)
      {
         if (handler.isActive)
            handler.beginTick();
      }

      ALLEGRO_EVENT event;
      while (al_get_next_event(_eventQueue, &event))
      {
         if (event.type in _eventHandlers)
         {
            foreach (handler; _eventHandlers[event.type])
               handler(event);
         }

         foreach (handler, dummy; _lowLevelEventHandlers)
         {
            if (handler.isActive)
               handler.handleEvent(event);
         }

         doPostHandlingEventCleanup(event);
      }

      foreach (handler, dummy; _lowLevelEventHandlers)
      {
         if (handler.isActive)
            handler.endTick();
      }
   }

   /**
    * Causes a draw event to be generated. This must be called from the main
    * game loop. All drawing should be made in response to draw events.
    *
    * Parameters:
    *    deltaT = The wall time, in seconds, elapsed since the last time this
    *       function was called.
    */
   public final void triggerDrawEvent(double deltaT)
   {
      // Construct the event structure
      _drawingTime += deltaT;
      ALLEGRO_EVENT drawEvent;
      drawEvent.user.type = FEWDEE_EVENT_DRAW;
      drawEvent.user.deltaTime = deltaT;
      drawEvent.user.totalTime = _drawingTime;
      drawEvent.user.timeSinceTick = _drawingTime - _tickTime;

      // Call the handlers
      if (FEWDEE_EVENT_DRAW in _eventHandlers)
      {
         foreach (handler; _eventHandlers[FEWDEE_EVENT_DRAW])
            handler(drawEvent);
      }

      // Call the low-level event handlers
      foreach (handler, dummy; _lowLevelEventHandlers)
         handler.handleEvent(drawEvent);

      // And flip the buffers
      al_flip_display();
   }

   /**
    * Posts an event to the event queue.
    *
    * Parameters:
    *    event = The event to post.
    */
   package final void postEvent(ref ALLEGRO_EVENT event)
   {
      al_emit_user_event(&_customEventSource, &event, null);
   }

   /**
    * Returns the one and only event queue we use. This is accessible by other
    * FewDee modules, because they need to register themselves as event sources
    * (displays, for example, must register and unregister themselves as event
    * sources as they are created and destroyed).
    */
   package final @property inout(ALLEGRO_EVENT_QUEUE*) eventQueue() inout
   {
      return _eventQueue;
   }

   /**
    * The drawing time, which is like the tick time ($(D _tickTime)), but may
    * get temporarily ahead of it, if multiple "draw" events happen between two
    * "tick" events.
    *
    * This is the number of seconds elapsed since an arbitrary instant (the
    * "epoch"). It gets updated whenever $(D triggerDrawEvent()) or $(D
    * triggerTickEvent()) is called.
    */
   private double _drawingTime = 0.0;

   /**
    * The tick time. This is the number of seconds elapsed since an arbitrary
    * instant (the "epoch"), which gets updated whenever $(D triggerTickEvent())
    * is called.
    */
   private double _tickTime = 0.0;

   /// The source of custom events.
   private ALLEGRO_EVENT_SOURCE _customEventSource;

   /**
    * The one and only event queue. Notice that draw events ($(D
    * FEWDEE_EVENT_DRAW)) are never added here (nor in any other event queue);
    * they are handled separately, in $(D triggerDrawEvent()).
    */
   private ALLEGRO_EVENT_QUEUE* _eventQueue;
}


/**
 * Performs any necessary cleanup in an event after it has been processed (that
 * is, all the event handlers interested in this event have already been
 * called).
 */
private void doPostHandlingEventCleanup(ref ALLEGRO_EVENT event)
{
   if (event.type == FEWDEE_EVENT_SPRITE_ANIMATION)
   {
      // Assigning null to 'sprite' will cause any previously 'Sprite' to be
      // removed from the list of GC roots and will unpin it from its current
      // memory position.
      event.user.sprite = null;
   }
}


/**
 * The Event Manager singleton. Provides access to the one and only $(D
 * EventManagerImpl) instance.
 */
public class EventManager
{
   mixin LowLockSingleton!EventManagerImpl;
}



//
// Unit tests
//

version (unittest)
{
   // A dummy event handler
   void aHandler(in ref ALLEGRO_EVENT e) { }
} // version (unittest)

// EventManagerImpl.addHandler()
unittest
{
   import std.functional;
   import fewdee.engine;

   scope crank = new Crank();
   auto em = EventManager.instance; // spare some typing

   assert(em._eventHandlers.length == 0);

   immutable id1 = em.addHandler(ALLEGRO_EVENT_KEY_DOWN, toDelegate(&aHandler));
   immutable id2 = em.addHandler(ALLEGRO_EVENT_TIMER, toDelegate(&aHandler));
   immutable id3 = em.addHandler(ALLEGRO_EVENT_KEY_DOWN, toDelegate(&aHandler));
   immutable id4 = em.addHandler(ALLEGRO_EVENT_KEY_UP, toDelegate(&aHandler));
   immutable id5 = em.addHandler(FEWDEE_EVENT_DRAW, toDelegate(&aHandler));

   // Returned IDs must be unique
   assert(id1 != id2);
   assert(id1 != id3);
   assert(id1 != id4);
   assert(id1 != id5);
   assert(id2 != id3);
   assert(id2 != id4);
   assert(id2 != id5);
   assert(id3 != id4);
   assert(id3 != id5);
   assert(id4 != id5);

   // The interface of the EventManagerImpl class alone doesn't provide many
   // ways to check if addHandler() is working. From this point on, we check if
   // certain implementation details are behaving as expected. Not really nice,
   // but that's the best I can do without doing changes I am unwilling to do.
   assert(ALLEGRO_EVENT_KEY_DOWN in em._eventHandlers);
   assert(ALLEGRO_EVENT_TIMER in em._eventHandlers);
   assert(ALLEGRO_EVENT_KEY_UP in em._eventHandlers);
   assert(FEWDEE_EVENT_DRAW in em._eventHandlers);
   assert(em._eventHandlers.length == 4);

   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 2);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 1);
}

// EventManagerImpl.removeHandler()
unittest
{
   import std.functional;
   import fewdee.engine;

   scope crank = new Crank();
   auto em = EventManager.instance; // spare some typing

   immutable id1 = em.addHandler(ALLEGRO_EVENT_KEY_DOWN, toDelegate(&aHandler));
   immutable id2 = em.addHandler(ALLEGRO_EVENT_TIMER, toDelegate(&aHandler));
   immutable id3 = em.addHandler(ALLEGRO_EVENT_KEY_DOWN, toDelegate(&aHandler));
   immutable id4 = em.addHandler(ALLEGRO_EVENT_KEY_UP, toDelegate(&aHandler));
   immutable id5 = em.addHandler(FEWDEE_EVENT_DRAW, toDelegate(&aHandler));

   // Again, let's test by checking the internal state
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 2);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 1);

   em.removeHandler(id1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 1);

   em.removeHandler(id5);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 0);

   em.removeHandler(id3);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 0);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 1);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 0);

   em.removeHandler(id2);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 0);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 0);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 1);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 0);

   em.removeHandler(id4);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_DOWN].length == 0);
   assert(em._eventHandlers[ALLEGRO_EVENT_TIMER].length == 0);
   assert(em._eventHandlers[ALLEGRO_EVENT_KEY_UP].length == 0);
   assert(em._eventHandlers[FEWDEE_EVENT_DRAW].length == 0);
}
