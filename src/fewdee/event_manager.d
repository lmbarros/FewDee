/**
 * FewDee's Event Manager and related definitions.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event_manager;

// import std.exception; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
import allegro5.allegro;
import fewdee.engine;
import fewdee.internal.singleton;


/**
 * The real implementation of the Event Manager. Users shall use this through
 * the $(D EventManager) class.
 */
private class EventManagerImpl
{
   private this()
   {
      al_init_user_event_source(&_customEventSource);
      scope (failure)
         al_destroy_user_event_source(&_customEventSource);

      _eventQueue = al_create_event_queue();

      // TODO: Error checking! xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // mixin (makeInitCode("(TheEventQueue !is null)",
      //                     "al_destroy_event_queue(TheEventQueue)",
      //                     "Error creating event queue."));

      al_register_event_source(_eventQueue, al_get_mouse_event_source());
      al_register_event_source(_eventQueue, al_get_keyboard_event_source());
      al_register_event_source(_eventQueue, al_get_joystick_event_source());
      al_register_event_source(_eventQueue, &_customEventSource);

      Core.isEventManagerInited = true;
   }


   package @property inout(ALLEGRO_EVENT_QUEUE*) eventQueue() inout
   {
      return _eventQueue;
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // TODO: shouldn't be necessary. Now, used in Core.run(), because they
   // generate the custom FEWDEE_EVENT_TICK events.
   package @property inout(ALLEGRO_EVENT_SOURCE*) customEventSource() inout
   {
      return &_customEventSource;
   }

   package void finalize()
   {
      al_destroy_event_queue(_eventQueue);
      al_destroy_user_event_source(&_customEventSource);
   }

   /// The source of custom events.
   private ALLEGRO_EVENT_SOURCE _customEventSource;

   /// The one and only event queue.
   private ALLEGRO_EVENT_QUEUE* _eventQueue;
}



/**
 * The Event Manager singleton. Provides access to the one and only $(D
 * EventManagerImpl) instance.
 */
public class EventManager
{
   mixin LowLockSingleton!EventManagerImpl;
}
