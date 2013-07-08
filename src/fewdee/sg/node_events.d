/**
 * GUI-like events for scene graph nodes.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.node_events;

import allegro5.allegro;
import std.conv;
import fewdee.event;
import fewdee.low_level_event_handler;
import fewdee.sg.node;


/// The possible types of GUI-like events.
public enum EventType
{
   /**
    * Mouse has moved on the registered object (either because the mouse pointer
    * itself moved or because the object has moved). The event passed to the
    * callback is of "user" type, without any useful information.
    */
   MOUSE_MOVE,

   /**
    * Mouse has entered in the area of the registered object (either because the
    * mouse pointer itself moved or because the object has moved). The event
    * passed to the callback is of "user" type, without any useful information.
    */
   MOUSE_ENTER,

   /**
    * Mouse has left the area of the registered object (either because the mouse
    * pointer itself moved or because the object has moved). The event passed to
    * the callback is of "user" type, without any useful information.
    */
   MOUSE_LEAVE,

   /**
    * Mouse button was pressed down in the registered object. The event passed
    * to the callback is of "mouse" type, and can be inspected to get
    * information like which button was pressed.
    */
   MOUSE_DOWN,

   /**
    * Mouse button was released in the registered object. The event passed to
    * the callback is of "mouse" type, and can be inspected to get information
    * like which button was released.
    */
   MOUSE_UP,

   /**
    * Mouse button was clicked in the registered object. The event passed to the
    * callback is of "mouse" type, and can be inspected to get information like
    * which button was clicked.
    */
   CLICK,

   /**
    * Mouse button was double-clicked in the registered object. The event passed
    * to the callback is of "mouse" type, and can be inspected to get
    * information like which button was double-clicked.
    */
   DOUBLE_CLICK,
}


/**
 * The type of callbacks called when node events happen. What exactly is
 * passed in the $(D event) parameter depends on what event is being handled;
 * for more information, please see the documentation of $(D EventType). The
 * $(D node) parameter gets the node on which the event was generated (for
 * example, the node clicked).
 */
public alias void delegate(ref in ALLEGRO_EVENT event, Node node)
   NodeEventCallback_t;



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
    * Adds a callback for a GUI-like event.
    *
    * Parameters:
    *   obj = The node receiving the event.
    *   event = The desired event type.
    *   callback = The callback to run.
    */
   public final void addHandler(
      Node obj, EventType event, NodeEventCallback_t callback)
   {
      _eventCallbacks[obj][event] ~= callback;
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
      foreach (obj, dummy; _eventCallbacks)
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
    * Calls all event callbacks of a given event type registered for a given
    * node.
    */
   private final void callEventCallbacks(Node node, EventType eventType,
                                         in ref ALLEGRO_EVENT event)
   {
      foreach (callback; _eventCallbacks[node][eventType])
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
            callEventCallbacks(_nodeUnderMouse, EventType.MOUSE_MOVE, event);
         }
      }
      else // nodeUnderMouse != _prevNodeUnderMouse
      {
         if (_prevNodeUnderMouse !is null)
         {
            callEventCallbacks(_prevNodeUnderMouse, EventType.MOUSE_LEAVE,
                               event);
         }

         if (_nodeUnderMouse !is null)
            callEventCallbacks(_nodeUnderMouse, EventType.MOUSE_ENTER, event);
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
         callEventCallbacks(_nodeUnderMouse, EventType.MOUSE_DOWN, event);

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

         callEventCallbacks(_nodeUnderMouse, EventType.MOUSE_UP, event);

         // Now, the trickier ones: "Click" and "DoubleClick"
         if (_nodeUnderMouse == _nodeThatGotMouseDown[button])
         {
            callEventCallbacks(_nodeUnderMouse, EventType.CLICK, event);

            if (_time - _timeOfLastClick[button] < DOUBLE_CLICK_INTERVAL
                && _nodeUnderMouse == _nodeThatGotClick[button])
            {
               callEventCallbacks(_nodeUnderMouse, EventType.DOUBLE_CLICK,
                                  event);
            }

            _nodeThatGotClick[button] = _nodeUnderMouse;
            _timeOfLastClick[button] = _time;
         }
      }
   }

   /// The time, in seconds, elapsed since this object started running.
   private double _time = 0.0;

   /**
    * All the event callbacks.
    *
    * $(D _eventCallbacks[MyNode][EventType.CLICK]) gets an array with all
    * callbacks for the "click" event of $(D MyNode).
    */
   private NodeEventCallback_t[][EventType][Node] _eventCallbacks;

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
