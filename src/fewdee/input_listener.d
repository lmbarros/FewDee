/**
 * Listens to input events and make them available in a way that is useful to
 * implement a "configure input" screen.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_listener;

import allegro5.allegro;
import fewdee.input_manager;
import fewdee.low_level_event_handler;


/// Description of a listened event.
public struct ListenedEvent
{
   /// The event source.
   public InputSource source;

   /// The joystick button number or the keyboard key code.
   public int code;
}



/**
 * Listens to input events and make them available in a way that is useful to
 * implement a "configure input" screen.
 *
 * Basically, an $(InputListener) will listen to user input until the first
 * input event is triggered; this event is saved and can be queried. In a
 * typical usage, you'd show a message like "press the key you want to use for
 * jumping"; then start an $(InputListener) and query it until an event is
 * available; then you use this information to configure the game input.
 *
 * The $(D InputListener) has properties allowing to configure its behavior in
 * some ways.
 *
 * You should always destroy the $(D InputListener) once you don't need
 * anymore. If the $(D InputListener) remains alive, it will waste memory and
 * CPU cycles.
 *
 * TODO: Maybe this should be a singleton? Perhaps it should be part of the $(D
 *    InputManager)? This could be a way to avoid the problem of "please destroy
 *    the $(D InputListener) or it will remain alive wasting resources forever."
 */
class InputListener: LowLevelEventHandler
{
   /**
    * The event listened.
    *
    * This contains valid data only if $(D hasListened) is $(D true).
    */
   public final @property ListenedEvent listenedEvent() inout
   {
      return _listenedEvent;
   }

   /// Ditto.
   private ListenedEvent _listenedEvent;

   /**
    * Starts listening for a new input event.
    *
    * An $(D InputListener) starts in a "not listening" state; you must call
    * this to start listening. You can also call this after listening to an
    * event, if you want to use the same $(D InputListener) to listen to more
    * events.
    *
    * It is OK to change the $(D InputListener)'s properties before
    * calling $(D startListening()).
    */
   public final void startListening()
   {
      _listenedEvent = typeof(_listenedEvent).init;
      _isListening = true;
   };

   /**
    * Did this $(D InputListener) listen to an event?
    *
    * If this is $(D true), $(D listenedEvent) will contain a valid event.
    */
   public final @property bool hasListened()
   {
      return _listenedEvent.source != InputSource.INVALID;
   }

   /**
    * Adds some key codes ($(D ALLEGRO_KEY_*)) to the list of keys that will be
    * ignored by the $(D InputListener).
    *
    * Unlike $(D setIgnoredKeys()), this function doesn't clear the current list
    * of ignored keys.
    */
   public final void addIgnoredKeys(int[] keyCodes...)
   {
      foreach (key; keyCodes)
         _ignoredKeys[key] = true;
   }

   /// Clears the list of keys that will be ignored by the $(D InputListener).
   public final void clearIgnoredKeys()
   {
      _ignoredKeys = typeof(_ignoredKeys).init;
   }

   /**
    * The key codes ($(D ALLEGRO_KEY_*)) of the keys that will be ignored by the
    * $(D InputListener).
    *
    * By default, no key is ignored, but you may wish to ignore keys which, for
    * some reason, have hardcoded bindings in your game. Another "good" key to
    * ignore is the key used to "cancel" the user input customization (like
    * "Press the key you want to use for jumping, or Esc to cancel.").
    */
   public final void setIgnoredKeys(int[] keyCodes...)
   {
      clearIgnoredKeys();
      addIgnoredKeys(keyCodes);
   }

   /// Ditto.
   public final int[] ignoredKeys() inout
   {
      return _ignoredKeys.keys;
   }

   /// Ditto.
   private bool[int] _ignoredKeys; // used as a set, Boolean value is ignored

   /**
    * A bit mask (of $(D InputSource)s) with the input sources that will be
    * listened by this $(D InputListener).
    *
    * By default, all input sources are limited, but you may wish to limit this
    * to, say, "only the keyboard" or "only the second and third joysticks".
    */
   public final void validInputSources(uint value)
   {
      _validInputSources = value;
   }

   /// Ditto.
   public final uint validInputSources() inout
   {
      return _validInputSources;
   }

   /// Ditto.
   private uint _validInputSources = ~0;

   // Inherit docs.
   public override void handleEvent(in ref ALLEGRO_EVENT event)
   {
      // Do nothing if we are not actively listening.
      if (!_isListening)
         return;

      // Ignore "invalid" input sources
      const source = InputManager.inputSource(event);

      if ((source & _validInputSources) == 0)
         return;

      // Handle events, updating _listenedEvent if appropriate
      switch (event.type)
      {
         case ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN:
         {
            _listenedEvent.source = source;
            _listenedEvent.code = event.joystick.button;
            _isListening = false;
            return;
         }

         case ALLEGRO_EVENT_KEY_DOWN:
         {
            const key = event.keyboard.keycode;

            // Ignore keys the user requested to ignore
            if (key in _ignoredKeys)
               return;

            // We got an event we are interested in; update _listenedEvent
            _listenedEvent.source = InputSource.KEYBOARD;
            _listenedEvent.code = event.keyboard.keycode;

            // And, since, we got an event, we should not listen anymore.
            _isListening = false;

            return;
         }

         default:
            return;
      }
   }

   /// Are we actively listening right now?
   private bool _isListening = false;
}
