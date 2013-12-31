/**
 * Helpful data structures to manage event handlers.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event_handler_set;


/**
 * A collection of delegates (event handlers, presumably) that accepts different
 * types of events.
 *
 * Each added handler has an ID that can be used to remove it from the set
 * (without having to provide the event type nor the event handler itself).
 *
 * A mechanism to call all event handlers of a given type is provided.
 *
 * Parameters:
 *    HandlerType = The type of the event handlers. This is typically a delegate
 *       type, but the implementation actually accepts any type here.
 *    EventTypeType = The type used to represent the event types.
 */
public struct EventHandlerSet(HandlerType, EventTypeType)
{
   /// The type used to represent an event handler ID.
   public alias size_t handlerID;

   /**
    * A handler ID that is guaranteed to be different to any real event handler
    * ID.
    */
   public enum invalidHandlerID = 0;

   /**
    * Adds an event handler of a given type.
    *
    * Parameters:
    *    type = The event type.
    *    handler = The event handler itself.
    *
    * Returns:
    *    An ID that can be later passed to $(D remove()) in order to remove the
    *    handler just added.
    */
   public final handlerID add(EventTypeType type, HandlerType handler)
   {
      const id = _nextHandlerID++;
      _eventHandlers[type][id] = handler;
      return id;
   }

   /**
    * Removes an event handler from the set.
    *
    * Parameters:
    *    id = The ID of the handler to remove. If there is no handler with this
    *       ID, nothing happens. (Corollary: it is OK to pass $(D
    *       invalidHandlerID) to this method; nothing will happen.)
    *
    * Returns:
    *    $(D true) if the handler was removed; $(D false) if not (which means
    *    that no handler with the given ID was found).
    */
   public final bool remove(handlerID id)
   {
      foreach(type, handlers; _eventHandlers)
      {
         if (id in handlers)
         {
            handlers.remove(id);
            if (handlers.length == 0)
               _eventHandlers.remove(type);
            return true;
         }
      }

      return false;
   }

   /**
    * Call all event handlers added for a given event type.
    *
    * Parameters:
    *    type = The event type whose handlers will be called.
    *    params = The parameters to pass to the event handlers.
    */
   public final void callHandlers(Params...)(EventTypeType type, Params params)
   {
      if (type !in _eventHandlers)
         return;

      foreach (handler; _eventHandlers[type])
         handler(params);
   }

   /// Returns the number of handlers of a given type.
   public final size_t handlersCount(EventTypeType type)
   {
      auto bucket = type in _eventHandlers;
      if (bucket)
         return bucket.length;
      else
         return 0;
   }

   /// Returns the event types currently present in the set.
   public final @property EventTypeType[] types() const
   {
      return _eventHandlers.keys;
   }

   /// The next ID to be returned by $(D add()).
   private handlerID _nextHandlerID = invalidHandlerID + 1;

   /**
    * The event handlers stored in the set.
    *
    * $(D _eventHandlers[type]) yields the collection of handlers with the $(D
    * type) bucket. The collection is a map in which each handler is indexed by
    * its ID.
    */
   private HandlerType[handlerID][EventTypeType] _eventHandlers;
}

///
unittest
{
   alias void delegate(int x, string s) eventHandler;
   enum EventType { A, B }

   int theInt;
   string theString;

   void handler1(int x, string s)
   {
      theInt = 100 + x;
      theString = "1: " ~ s;
   }

   void handler2(int x, string s)
   {
      theInt += 200 + x;
      theString = "2: " ~ s;
   }

   void handler3(int x, string s)
   {
      theInt += 1_000_000;
   }

   EventHandlerSet!(eventHandler, EventType) eventSet;

   // Add some handlers
   const id1 = eventSet.add(EventType.A, &handler1);
   const id2 = eventSet.add(EventType.B, &handler2);
   const id3 = eventSet.add(EventType.B, &handler3);

   // Call handlers of type A (there is just one of them) check results
   eventSet.callHandlers(EventType.A, 5, "Hello");
   assert(theInt == 105);
   assert(theString == "1: Hello");

   // Call handlers of type B (two of them this time) check results
   theInt = 0;
   eventSet.callHandlers(EventType.B, 3, "Goodbye");
   assert(theInt == 1_000_203);
   assert(theString == "2: Goodbye");

   // Now, remove a B-type handler and call B handlers again
   theInt = 0;
   eventSet.remove(id3);
   eventSet.callHandlers(EventType.B, 4, "Good evening");
   assert(theInt == 204);
   assert(theString == "2: Good evening");

   // Remove the only A-type handler, call A handlers; nothing shall happen
   eventSet.remove(id1);
   eventSet.callHandlers(EventType.A, 8, "Good night");
   assert(theInt == 204);
   assert(theString == "2: Good evening");
}


// Tests methods add(), remove() and handlersCount()
unittest
{
   alias void delegate(int x, string s) eventHandler;
   enum EventType { A, B, C, D }

   void aHandler(int x, string s) { }

   EventHandlerSet!(eventHandler, EventType) eventSet;

   // Initially, all buckets should be zero-sized.
   assert(eventSet.handlersCount(EventType.A) == 0);
   assert(eventSet.handlersCount(EventType.B) == 0);
   assert(eventSet.handlersCount(EventType.C) == 0);
   assert(eventSet.handlersCount(EventType.D) == 0);

   // Add some handlers
   const id1 = eventSet.add(EventType.B, &aHandler);
   const id2 = eventSet.add(EventType.D, &aHandler);
   const id3 = eventSet.add(EventType.B, &aHandler);

   // Ensure the IDs are the expected
   assert(id1 != eventSet.invalidHandlerID);
   assert(id2 == id1 + 1);
   assert(id3 == id1 + 2);

   // Now we should have some handlers for some event types
   assert(eventSet.handlersCount(EventType.A) == 0);
   assert(eventSet.handlersCount(EventType.B) == 2);
   assert(eventSet.handlersCount(EventType.C) == 0);
   assert(eventSet.handlersCount(EventType.D) == 1);

   // Now, remove a handler and check everything again
   eventSet.remove(id3);

   assert(eventSet.handlersCount(EventType.A) == 0);
   assert(eventSet.handlersCount(EventType.B) == 1);
   assert(eventSet.handlersCount(EventType.C) == 0);
   assert(eventSet.handlersCount(EventType.D) == 1);

   // Now, remove the remaining two handlers, re-check
   eventSet.remove(id1);
   eventSet.remove(id2);

   assert(eventSet.handlersCount(EventType.A) == 0);
   assert(eventSet.handlersCount(EventType.B) == 0);
   assert(eventSet.handlersCount(EventType.C) == 0);
   assert(eventSet.handlersCount(EventType.D) == 0);
}
