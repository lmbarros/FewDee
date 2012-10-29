/**
 * GUI-like events for scene graph nodes.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.guish;

import allegro5.allegro;
import std.conv;
import twodee.node;


/// The possible types of GUI-like events.
enum EventType
{
   MOUSE_MOVE,
   MOUSE_ENTER,
   MOUSE_LEAVE,
   MOUSE_DOWN,
   MOUSE_UP,
   CLICK,
   DOUBLE_CLICK,
}


/**
 * Generates GUI-like events for registered Nodes.
 */
class GUIshEventGenerator
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // TODO: must pass some parameter... need to know which mouse button was
   //       pressed, for example.
   alias void delegate() handler_t;


   /**
    * Must be called whenever an event arrives, so that the GUI-like events can
    * be properly generated.
    */
   public void onEvent(in ref ALLEGRO_EVENT event)
   {
      switch (event.type)
      {
         case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
            return handleMouseButtonDownEvent(event);

         case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
            return handleMouseButtonUpEvent(event);

         default:
            return; // ignore
      }
   }


   /**
    * Must be called on every thick, so that the GUI-like events can be properly
    * generated.
    *
    * One could think that handling most of these events in a "mouse axis" event
    * would work just as well and be more efficient. The truth is, it wouldn't
    * work just as well. Mouse enter, mouse leave and mouse move events in GUIsh
    * are "relative": if a moving node crosses a static mouse pointer, the
    * events shall be generated. This is by design.
    */
   public void tick(double deltaTime)
   {
      time_ += deltaTime;

      ALLEGRO_MOUSE_STATE mouseState;
      al_get_mouse_state(&mouseState);

      updatePickingData(mouseState.x, mouseState.y);

      // Trigger the events
      if (nodeUnderMouse_ == prevNodeUnderMouse_)
      {
         if (prevNodeUnderMouse_ !is null
             && positionUnderMouse_ != prevPositionUnderMouse_)
         {
            callHandlers(nodeUnderMouse_, EventType.MOUSE_MOVE);
         }
      }
      else // nodeUnderMouse != prevNodeUnderMouse_
      {
         if (prevNodeUnderMouse_ !is null)
            callHandlers(prevNodeUnderMouse_, EventType.MOUSE_LEAVE);

         if (nodeUnderMouse_ !is null)
            callHandlers(nodeUnderMouse_, EventType.MOUSE_ENTER);
      }
   }


   /**
    * Adds a handler for a GUI-like event.
    *
    * Parameters:
    *   obj = The node receiving the event.
    *   event = The desired event type.
    *   handler = The handler to run.
    */
   public void addHandler(Node obj, EventType event,
                          handler_t handler)
   {
      import std.stdio;
      handlers_[obj][event] ~= handler;
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
      foreach(obj, dummy; handlers_)
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
    * Calls all event handlers of a given event type registered for a given
    * node.
    */
   private void callHandlers(Node obj, EventType eventType)
   {
      foreach(handler; handlers_[obj][eventType])
         handler();
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
         callHandlers(nodeUnderMouse_, EventType.MOUSE_DOWN);

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

         callHandlers(nodeUnderMouse_, EventType.MOUSE_UP);

         // Now, the trickier ones: "Click" and "DoubleClick"
         if (nodeUnderMouse_ == nodeThatGotMouseDown_[button])
         {
            callHandlers(nodeUnderMouse_, EventType.CLICK);

            if (time_ - timeOfLastClick_[button] < DOUBLE_CLICK_INTERVAL
                && nodeUnderMouse_ == nodeThatGotClick_[button])
            {
               callHandlers(nodeUnderMouse_, EventType.DOUBLE_CLICK);
            }

            nodeThatGotClick_[button] = nodeUnderMouse_;
            timeOfLastClick_[button] = time_;
         }
      }
   }


   /// The time, in seconds, elapsed since this object started running.
   private double time_ = 0.0;

   /**
    * All the event handlers. handlers_[MyNode][EventType.CLICK] gets an array
    * with all handlers for the "click" event of MyNode.
    */
   private handler_t[][EventType][Node] handlers_;

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
