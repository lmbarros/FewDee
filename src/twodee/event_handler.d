/**
 * An interface to be implemented by whoever wants to receive events.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.event_handler;

import allegro5.allegro;


/**
 * An interface to be implemented by whoever wants to receive events. Notice,
 * though, that simply implementing this interface will not make a class
 * magically receive events.
 */
interface EventHandler
{
   /**
    * Handles an incoming event.
    *
    * Parameters:
    *    event = The event to handle.
    *
    * Return: Shall return true if the event was effectively handled, or false
    *    otherwise.
    */
   public bool handleEvent(in ref ALLEGRO_EVENT event);
}
