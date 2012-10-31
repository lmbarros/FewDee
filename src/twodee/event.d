/**
 * TwoDee events and event-related stuff.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.event;

import allegro5.allegro;
import std.math;

enum
{
   /**
    * An event sent on every game engine tick. Handling it is the preferred way
    * to update the world state. The time, in seconds, elapsed during this tick
    * is encoded in the event "user parameters".
    *
    * See_Also encodeDeltaTime, decodeDeltaTime
    */
   TWODEE_EVENT_TICK = ALLEGRO_GET_EVENT_TYPE('T','w','o','D'),
}


/**
 * Encodes a delta time (in seconds) and stores it in a given ALLEGRO_USER_EVENT
 * (assumed to be of type TWODEE_EVENT_TICK).
 */
void encodeDeltaTime(
   ref ALLEGRO_USER_EVENT event, double deltaTime)
{
   event.data1 = cast(typeof(event.data1))
      (floor(deltaTime));
   event.data2 = cast(typeof(event.data1))
      ((deltaTime - event.data1) * 1_000_000_000);
}


/**
 * Decodes the delta time stored in a given ALLEGRO_USER_EVENT (assumed to be of
 * type TWODEE_EVENT_TICK) and returns it (as the time in seconds elapsed during
 * that tick).
 */
double decodeDeltaTime(const ref ALLEGRO_USER_EVENT event)
{
   return event.data1 + (event.data2 / 1_000_000_000.0);
}
