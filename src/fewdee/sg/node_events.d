/**
 * GUI-like events for scene graph nodes.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.node_events;

import allegro5.allegro;
import fewdee.event;
import fewdee.low_level_event_handler;
import fewdee.sg.node;


/// The possible types of GUI-like events.
public enum EventType
{
   /**
    * Mouse has moved on the registered object (either because the mouse pointer
    * itself moved or because the object has moved). The event passed to the
    * handler is of "user" type, without any useful information.
    */
   MOUSE_MOVE,

   /**
    * Mouse has entered in the area of the registered object (either because the
    * mouse pointer itself moved or because the object has moved). The event
    * passed to the handler is of "user" type, without any useful information.
    */
   MOUSE_ENTER,

   /**
    * Mouse has left the area of the registered object (either because the mouse
    * pointer itself moved or because the object has moved). The event passed to
    * the handler is of "user" type, without any useful information.
    */
   MOUSE_LEAVE,

   /**
    * Mouse button was pressed down in the registered object. The event passed
    * to the handler is of "mouse" type, and can be inspected to get information
    * like which button was pressed.
    */
   MOUSE_DOWN,

   /**
    * Mouse button was released in the registered object. The event passed to
    * the handler is of "mouse" type, and can be inspected to get information
    * like which button was released.
    */
   MOUSE_UP,

   /**
    * Mouse button was clicked in the registered object. The event passed to the
    * handler is of "mouse" type, and can be inspected to get information like
    * which button was clicked.
    */
   CLICK,

   /**
    * Mouse button was double-clicked in the registered object. The event passed
    * to the handler is of "mouse" type, and can be inspected to get information
    * like which button was double-clicked.
    */
   DOUBLE_CLICK,
}


/**
 * The type of handlers called when node events happen. What exactly is passed
 * in the $(D event) parameter depends on what event is being handled; for more
 * information, please see the documentation of $(D EventType). The $(D node)
 * parameter gets the node on which the event was generated (for example, the
 * node clicked).
 */
public alias void delegate(ref in ALLEGRO_EVENT event, Node node)
   NodeEventHandler;


/**
 * An opaque identifier identifying a $(D NodeEventHandler) added to an $(D
 * NodeEventsGenerator). It can be used to remove the updater function.
 */
public alias size_t NodeEventHandlerID;


/**
 * An "node event handler ID" that is guaranteed to never be equal to any real
 * node event handler ID. It is safe to pass $(D InvalidUpdaterFuncID) to $(D
 * NodeEventsGenerator.removeHandler()).
 */
public immutable NodeEventHandlerID InvalidNodeEventHandlerID = 0;



/// Generates GUI-like events for registered $(D Node)s.
class NodeEventsGenerator: LowLevelEventHandler
{
   /// Handles incoming events.
   public override void handleEvent(in ref ALLEGRO_EVENT event)
   {
      switch (event.type)
      {
         case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
            handleMouseButtonDownEvent(event);
            break;

         case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
            handleMouseButtonUpEvent(event);
            break;

         case FEWDEE_EVENT_TICK:
            handleTickEvent(event);
            break;

         default:
            break;
      }
   }

   /**
    * Adds a handler for a GUI-like event.
    *
    * Parameters:
    *   obj = The node receiving the event.
    *   event = The desired event type.
    *   handler = The handler to run when the event is triggered.
    *
    * Returns:
    *   A handle that can be passed to $(D removeHandler()) should you want to
    *   remove the event handler.
    */
   public final NodeEventHandlerID
   addHandler(Node obj, EventType event, NodeEventHandler handler)
   {
      _eventHandlers[obj][event][_nextEventHandlerID] = handler;
      return _nextEventHandlerID++;
   }

   /**
    * Removes the event handler whose handle is passed as parameter.
    *
    * Parameters:
    *    id = The handle (as returned by $(D addHandler)) of the event handler
    *       to be removed.
    *
    * Returns:
    *    $(D true) if the handler was removed; $(D false) if it was not (which
    *    means that no handler with the requested handle was found).
    *
    * TODO: "Clean" the data structure, by removing, for example, $(D
    *    _eventHandlers[node]) if no handler for $(D node) exists anymore.
    */
   public final bool removeHandler(NodeEventHandlerID id)
   {
      foreach (node, nodeData; _eventHandlers)
      {
         foreach (eventType, handlerList; nodeData)
         {
            if (handlerList.remove(id))
               return true;
         }
      }

      return false;
   }

   /// A point on the screen.
   private struct point { float x; float y; };

   /**
    * Updates $(D _prevNodeUnderMouse), $(D _prevPositionUnderMouse), $(D
    * _nodeUnderMouse) and $(D _positionUnderMouse).
    *
    * Parameters:
    *    mouseX = The mouse coordinate along the $(I x) axis.
    *    mouseY = The mouse coordinate along the $(I y) axis.
    */
   private final void updatePickingData(float mouseX, float mouseY)
   {
      Node currentNodeUnderMouse = null;
      foreach (obj, dummy; _eventHandlers)
      {
         if (obj.contains(mouseX, mouseY))
         {
            currentNodeUnderMouse = obj;
            break;
         }
      }

      point currentPositionUnderMouse;
      if (currentNodeUnderMouse !is null)
      {
         currentPositionUnderMouse = point(
            mouseX - currentNodeUnderMouse.aabb.left,
            mouseY - currentNodeUnderMouse.aabb.top);
      }

      _prevNodeUnderMouse = _nodeUnderMouse;
      _prevPositionUnderMouse = _positionUnderMouse;

      _nodeUnderMouse = currentNodeUnderMouse;
      _positionUnderMouse = currentPositionUnderMouse;
   }

   /**
    * Calls all event handlers of a given event type registered for a given
    * node.
    */
   private final void callEventHandlers(Node node, EventType eventType,
                                        in ref ALLEGRO_EVENT event)
   {
      foreach (callback; _eventHandlers[node][eventType])
         callback(event, node);
   }

   /**
    * Handles tick events, so that the GUI-like events can be properly
    * generated.
    *
    * One could think that handling most of these events in a "mouse axis" event
    * would work just as well and be more efficient. The truth is, it wouldn't
    * work just as well. Mouse enter, mouse leave and mouse move events are
    * "relative": if a moving node crosses a static mouse pointer, the events
    * shall be generated, even the mouse cursor itself is static. This is by
    * design.
    */
   private final void handleTickEvent(in ref ALLEGRO_EVENT event)
   {
      _time += event.user.deltaTime;

      ALLEGRO_MOUSE_STATE mouseState;
      al_get_mouse_state(&mouseState);

      updatePickingData(mouseState.x, mouseState.y);

      // Trigger the events
      if (_nodeUnderMouse == _prevNodeUnderMouse)
      {
         if (_prevNodeUnderMouse !is null
             && _positionUnderMouse != _prevPositionUnderMouse)
         {
            callEventHandlers(_nodeUnderMouse, EventType.MOUSE_MOVE, event);
         }
      }
      else // nodeUnderMouse != _prevNodeUnderMouse
      {
         if (_prevNodeUnderMouse !is null)
         {
            callEventHandlers(
               _prevNodeUnderMouse, EventType.MOUSE_LEAVE, event);
         }

         if (_nodeUnderMouse !is null)
            callEventHandlers(_nodeUnderMouse, EventType.MOUSE_ENTER, event);
      }
   }

   /// Handles a "mouse button down" event.
   private final void handleMouseButtonDownEvent(in ref ALLEGRO_EVENT event)
   in
   {
      assert(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN);
   }
   body
   {
      // Trigger a "MouseDown" signal.
      if (_nodeUnderMouse !is null)
         callEventHandlers(_nodeUnderMouse, EventType.MOUSE_DOWN, event);

      // Do the bookkeeping for "Click" and "DoubleClick"
      _nodeThatGotMouseDown[event.mouse.button] = _nodeUnderMouse;
   }

   /// Handles a "mouse button up" event.
   private final void handleMouseButtonUpEvent(in ref ALLEGRO_EVENT event)
   in
   {
      assert(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP);
   }
   body
   {
      enum DOUBLE_CLICK_INTERVAL = 0.3;

      if (_nodeUnderMouse !is null)
      {
         immutable button = event.mouse.button;

         callEventHandlers(_nodeUnderMouse, EventType.MOUSE_UP, event);

         // Now, the trickier ones: "Click" and "DoubleClick"
         if (_nodeUnderMouse == _nodeThatGotMouseDown[button])
         {
            callEventHandlers(_nodeUnderMouse, EventType.CLICK, event);

            if (_time - _timeOfLastClick[button] < DOUBLE_CLICK_INTERVAL
                && _nodeUnderMouse == _nodeThatGotClick[button])
            {
               callEventHandlers(
                  _nodeUnderMouse, EventType.DOUBLE_CLICK, event);
            }

            _nodeThatGotClick[button] = _nodeUnderMouse;
            _timeOfLastClick[button] = _time;
         }
      }
   }

   /// The time, in seconds, elapsed since this object started running.
   private double _time = 0.0;

   /**
    * All the event handlers.
    *
    * $(D _eventHandlers[MyNode][EventType.CLICK]) gets an associative array
    * with all handlers for the "click" event of $(D MyNode), indexed by their
    * node event handler IDs.
    */
   private NodeEventHandler[NodeEventHandlerID][EventType][Node] _eventHandlers;

   /**
    * The next node event handler ID to use. The same sequence of IDs is used
    * for all event types and nodes.
    */
   private NodeEventHandlerID _nextEventHandlerID =
      InvalidNodeEventHandlerID + 1;

   /// The node currently under the mouse pointer.
   private Node _nodeUnderMouse;

   /**
    * The position (in the node coordinate system) of $(D _nodeUnderMouse) (the
    * node currently under the mouse pointer).
    */
   private point _positionUnderMouse;

   /// The node previously under the mouse pointer.
   private Node _prevNodeUnderMouse;

   /**
    * The position (in the node coordinate system) of $(D _prevNodeUnderMouse)
    * (the node previously under the mouse pointer).
    */
   private point _prevPositionUnderMouse;

   /**
    * The size of arrays indexed by the mouse button number.
    *
    * Allegro stores the mouse buttons state in a 32-bit unsigned integer and
    * therefore it can handle mice with up to 32 buttons. Since Allegro's mouse
    * button numbering starts at 1, the theoretical range of possible indices is
    * [1, 32]. We could add lots of "minus ones" throughout the code, but adding
    * one extra element in each array (and leaving index 0 unused) helps to keep
    * the code clean. That's why we use 33 here, instead of 32.
    *
    * By the way, 32 buttons is much more than the average number of fingers in
    * a human being, so supporting all of them may be an overkill. On the other
    * hand, supporting less than 32 buttons would be an arbitrary
    * limitation. How many buttons would be a reasonable limit? Since the
    * overhead per button isn't that big, we simply support all buttons Allegro
    * can possibly support.
    */
   private enum _mouseButtonArraySize = 33;

   /**
    * An array indicating (for every mouse button) which was the node that
    * received the last mouse down event. This is used to identify clicks.
    */
   private Node _nodeThatGotMouseDown[_mouseButtonArraySize];

   /**
    * An array indicating (for every mouse button) which was the node that
    * received the last click event. This is used to identify double clicks.
    */
   private Node _nodeThatGotClick[_mouseButtonArraySize];

   /**
    * An array indicating (for every mouse button) the time at which the last
    * click event has happened. This is used to identify double clicks.
    */
   double _timeOfLastClick[_mouseButtonArraySize];
}
