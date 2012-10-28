/**
 * Objects supporting GUI-like events.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.guish;

import allegro5.allegro;
import std.conv;


/**
 * An interface that must be implemented by objects that want to be able to
 * receive GUI-like events.
 */
interface GUIshObject
{
   /// Object's position, in pixels, measured from the left of the screen.
   public @property float left() const;

   /// Object's position, in pixels, measured from the top of the screen.
   public @property float top() const;

   /// Object's width, in pixels.
   public @property float width() const;

   /// Object's height, in pixels.
   public @property float height() const;

   /// Is the point (px, py) inside the object?
   public bool contains(float px, float py) const;
}


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
 * Generates GUI-like events for registered GUIshObjects.
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
    * are "relative": if a moving object crosses a static mouse pointer, the
    * events shall be generated. This is by design.
    */
   public void tick(double deltaTime)
   {
      time_ += deltaTime;

      ALLEGRO_MOUSE_STATE mouseState;
      al_get_mouse_state(&mouseState);

      updatePickingData(mouseState.x, mouseState.y);

      // Trigger the events
      if (objectUnderMouse_ == prevObjectUnderMouse_)
      {
         if (prevObjectUnderMouse_ !is null
             && positionUnderMouse_ != prevPositionUnderMouse_)
         {
            callHandlers(objectUnderMouse_, EventType.MOUSE_MOVE);
         }
      }
      else // objectUnderMouse != prevObjectUnderMouse_
      {
         if (prevObjectUnderMouse_ !is null)
            callHandlers(prevObjectUnderMouse_, EventType.MOUSE_LEAVE);

         if (objectUnderMouse_ !is null)
            callHandlers(objectUnderMouse_, EventType.MOUSE_ENTER);
      }
   }


   /**
    * Adds a handler for a GUI-like event.
    *
    * Parameters:
    *   obj = The object receiving the event.
    *   event = The desired event type.
    *   handler = The handler to run.
    */
   public void addHandler(GUIshObject obj, EventType event,
                          handler_t handler)
   {
      import std.stdio;
      handlers_[obj][event] ~= handler;
   }


   /// A point on the screen.
   private struct point { float x; float y; };


   /**
    * Updates prevObjectUnderMouse_, prevPositionUnderMouse_, objectUnderMouse_
    * and positionUnderMouse_.
    *
    * Parameters:
    *    mouseX = The mouse coordinate along the x axis.
    *    mouseY = The mouse coordinate along the y axis.
    */
   private void updatePickingData(float mouseX, float mouseY)
   {
      GUIshObject currentObjectUnderMouse = null;
      foreach(obj, dummy; handlers_)
      {
         if (obj.contains(mouseX, mouseY))
         {
            currentObjectUnderMouse = obj;
            break;
         }
      }

      point currentPositionUnderMouse;
      if (currentObjectUnderMouse !is null)
      {
         currentPositionUnderMouse = point(
            mouseX - currentObjectUnderMouse.left,
            mouseY - currentObjectUnderMouse.top);
      }

      prevObjectUnderMouse_ = objectUnderMouse_;
      prevPositionUnderMouse_ = positionUnderMouse_;

      objectUnderMouse_ = currentObjectUnderMouse;
      positionUnderMouse_ = currentPositionUnderMouse;
   }


   /**
    * Calls all event handlers of a given event type registered for a given
    * object.
    */
   private void callHandlers(GUIshObject obj, EventType eventType)
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
      if (objectUnderMouse_ !is null)
         callHandlers(objectUnderMouse_, EventType.MOUSE_DOWN);

      // Do the bookkeeping for "Click" and "DoubleClick"
      objectThatGotMouseDown_[event.mouse.button] = objectUnderMouse_;
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

      if (objectUnderMouse_ !is null)
      {
         immutable button = event.mouse.button;

         callHandlers(objectUnderMouse_, EventType.MOUSE_UP);

         // Now, the trickier ones: "Click" and "DoubleClick"
         if (objectUnderMouse_ == objectThatGotMouseDown_[button])
         {
            callHandlers(objectUnderMouse_, EventType.CLICK);

            if (time_ - timeOfLastClick_[button] < DOUBLE_CLICK_INTERVAL
                && objectUnderMouse_ == objectThatGotClick_[button])
            {
               callHandlers(objectUnderMouse_, EventType.DOUBLE_CLICK);
            }

            objectThatGotClick_[button] = objectUnderMouse_;
            timeOfLastClick_[button] = time_;
         }
      }
   }


   /// The time, in seconds, elapsed since this object started running.
   private double time_ = 0.0;

   /**
    * All the event handlers. handlers_[MyObject][EventType.CLICK] gets an array
    * with all handlers for the "click" event of MyObject.
    */
   private handler_t[][EventType][GUIshObject] handlers_;

   /// The object currently under the mouse pointer.
   private GUIshObject objectUnderMouse_;

   /**
    * The position (in the object coordinate system) of objectUnderMouse_ (the
    * object currently under the mouse pointer).
    */
   private point positionUnderMouse_;

   /// The object previously under the mouse pointer.
   private GUIshObject prevObjectUnderMouse_;

   /**
    * The position (in the object coordinate system) of prevObjectUnderMouse_
    * (the object previously under the mouse pointer).
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
    * An array indicating (for every mouse button) which was the object that
    * received the last mouse down event. This is used to identify clicks.
    */
   private GUIshObject objectThatGotMouseDown_[mouseButtonArraySize_];

   /**
    * An array indicating (for every mouse button) which was the object that
    * received the last click event. This is used to identify double clicks.
    */
   private GUIshObject objectThatGotClick_[mouseButtonArraySize_];

   /**
    * An array indicating (for every mouse button) the time at which the last
    * click event has happened. This is used to identify double clicks.
    */
   double timeOfLastClick_[mouseButtonArraySize_];
}
