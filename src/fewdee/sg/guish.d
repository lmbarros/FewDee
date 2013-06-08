/**
 * GUI-like events for scene graph nodes.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.guish;

import allegro5.allegro;
import std.conv;
import fewdee.event;
import fewdee.low_level_event_handler;
import fewdee.sg.node;


/// The possible types of GUI-like events.
enum EventType
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
 * Generates GUI-like events for registered Nodes.
 */
class GUIshEventGenerator: LowLevelEventHandler
{
   /**
    * The type of callbacks called when GUIsh events happen. What exactly is
    * passed in the "event" parameter depends on what event is being handled;
    * for more information, please see the documentation of EventType. The
    * "node" parameter gets the node on which the event was generated (for
    * example, the node clicked).
    */
   public alias void delegate(ref in ALLEGRO_EVENT event, Node node)
      EventCallback_t;

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
   public void addEventCallback(Node obj, EventType event,
                                EventCallback_t callback)
   {
      eventCallbacks_[obj][event] ~= callback;
   }


   /// A point on the screen.
   private struct point { float x; float y; };


   /**
    * Updates prevNodeUnderMouse_, prevPositionUnderMouse_, nodeUnderMouse_
    * and positionUnderMouse_.
    *
    * Parameters:
    *    mouseX = The mouse coordinate along the x axis.
    *    mouseY = The mouse coordinate along the y axis.
    */
   private void updatePickingData(float mouseX, float mouseY)
   {
      Node currentNodeUnderMouse = null;
      foreach(obj, dummy; eventCallbacks_)
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

      prevNodeUnderMouse_ = nodeUnderMouse_;
      prevPositionUnderMouse_ = positionUnderMouse_;

      nodeUnderMouse_ = currentNodeUnderMouse;
      positionUnderMouse_ = currentPositionUnderMouse;
   }


   /**
    * Calls all event callbacks of a given event type registered for a given
    * node.
    */
   private void callEventCallbacks(Node node, EventType eventType,
                                   in ref ALLEGRO_EVENT event)
   {
      foreach(callback; eventCallbacks_[node][eventType])
         callback(event, node);
   }


   /**
    * Handles tick events, so that the GUI-like events can be properly
    * generated.
    *
    * One could think that handling most of these events in a "mouse axis" event
    * would work just as well and be more efficient. The truth is, it wouldn't
    * work just as well. Mouse enter, mouse leave and mouse move events in GUIsh
    * are "relative": if a moving node crosses a static mouse pointer, the
    * events shall be generated. This is by design.
    */
   private void handleTickEvent(in ref ALLEGRO_EVENT event)
   {
      time_ += event.user.deltaTime;

      ALLEGRO_MOUSE_STATE mouseState;
      al_get_mouse_state(&mouseState);

      updatePickingData(mouseState.x, mouseState.y);

      // Trigger the events
      if (nodeUnderMouse_ == prevNodeUnderMouse_)
      {
         if (prevNodeUnderMouse_ !is null
             && positionUnderMouse_ != prevPositionUnderMouse_)
         {
            callEventCallbacks(nodeUnderMouse_, EventType.MOUSE_MOVE, event);
         }
      }
      else // nodeUnderMouse != prevNodeUnderMouse_
      {
         if (prevNodeUnderMouse_ !is null)
         {
            callEventCallbacks(prevNodeUnderMouse_, EventType.MOUSE_LEAVE,
                               event);
         }

         if (nodeUnderMouse_ !is null)
            callEventCallbacks(nodeUnderMouse_, EventType.MOUSE_ENTER, event);
      }
   }


   /// Handles a "mouse button down" event.
   private void handleMouseButtonDownEvent(in ref ALLEGRO_EVENT event)
   in
   {
      assert(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN);
   }
   body
   {
      // Trigger a "MouseDown" signal.
      if (nodeUnderMouse_ !is null)
         callEventCallbacks(nodeUnderMouse_, EventType.MOUSE_DOWN, event);

      // Do the bookkeeping for "Click" and "DoubleClick"
      nodeThatGotMouseDown_[event.mouse.button] = nodeUnderMouse_;
   }


   /// Handles a "mouse button up" event.
   private void handleMouseButtonUpEvent(in ref ALLEGRO_EVENT event)
   in
   {
      assert(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP);
   }
   body
   {
      enum DOUBLE_CLICK_INTERVAL = 0.3;

      if (nodeUnderMouse_ !is null)
      {
         immutable button = event.mouse.button;

         callEventCallbacks(nodeUnderMouse_, EventType.MOUSE_UP, event);

         // Now, the trickier ones: "Click" and "DoubleClick"
         if (nodeUnderMouse_ == nodeThatGotMouseDown_[button])
         {
            callEventCallbacks(nodeUnderMouse_, EventType.CLICK, event);

            if (time_ - timeOfLastClick_[button] < DOUBLE_CLICK_INTERVAL
                && nodeUnderMouse_ == nodeThatGotClick_[button])
            {
               callEventCallbacks(nodeUnderMouse_, EventType.DOUBLE_CLICK,
                                  event);
            }

            nodeThatGotClick_[button] = nodeUnderMouse_;
            timeOfLastClick_[button] = time_;
         }
      }
   }


   /// The time, in seconds, elapsed since this object started running.
   private double time_ = 0.0;

   /**
    * All the event callbacks. eventCallbacks_[MyNode][EventType.CLICK] gets an
    * array with all callbacks for the "click" event of MyNode.
    */
   private EventCallback_t[][EventType][Node] eventCallbacks_;

   /// The node currently under the mouse pointer.
   private Node nodeUnderMouse_;

   /**
    * The position (in the node coordinate system) of nodeUnderMouse_ (the
    * node currently under the mouse pointer).
    */
   private point positionUnderMouse_;

   /// The node previously under the mouse pointer.
   private Node prevNodeUnderMouse_;

   /**
    * The position (in the node coordinate system) of prevNodeUnderMouse_
    * (the node previously under the mouse pointer).
    */
   private point prevPositionUnderMouse_;

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
   private enum mouseButtonArraySize_ = 33;

   /**
    * An array indicating (for every mouse button) which was the node that
    * received the last mouse down event. This is used to identify clicks.
    */
   private Node nodeThatGotMouseDown_[mouseButtonArraySize_];

   /**
    * An array indicating (for every mouse button) which was the node that
    * received the last click event. This is used to identify double clicks.
    */
   private Node nodeThatGotClick_[mouseButtonArraySize_];

   /**
    * An array indicating (for every mouse button) the time at which the last
    * click event has happened. This is used to identify double clicks.
    */
   double timeOfLastClick_[mouseButtonArraySize_];
}
