/**
 * FewDee's Event Manager and related definitions.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event_manager;

import std.exception;
import allegro5.allegro;
import fewdee.core;
import fewdee.internal.singleton;


/**
 * The real implementation of the Event Manager. Users shall use this through
 * the $(D EventManager) class.
 */
private class EventManagerImpl
{
   /// Constructs the Event Manager.
   private this()
   {
      al_init_user_event_source(&_customEventSource);
      scope (failure)
         al_destroy_user_event_source(&_customEventSource);

      _eventQueue = al_create_event_queue();
      enforce(_eventQueue);
      scope (failure)
         al_destroy_event_queue(_eventQueue);

      al_register_event_source(_eventQueue, al_get_mouse_event_source());
      al_register_event_source(_eventQueue, al_get_keyboard_event_source());
      al_register_event_source(_eventQueue, al_get_joystick_event_source());
      al_register_event_source(_eventQueue, &_customEventSource);

      Core.isEventManagerInited = true;
   }

   /**
    * Returns the one and only event queue we use. This is accessible by other
    * FewDee modules, because they need to register themselves as event sources
    * (displays, for example, must register and unregister themselves as event
    * sources as they are created and destroyed).
    */
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

   /// Finalizes the Event Manager.
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
