/**
 * FewDee events and event-related stuff.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event;

import allegro5.allegro;
import std.math;

public enum
{
   /**
    * An event sent on every game engine tick. Handling it is the preferred way
    * to update the world state. The time elapsed during this tick and the total
    * time elapsed so far (both in seconds) are encoded in the event "user
    * parameters".
    *
    * See_Also: $(D deltaTime), $(D totalTime).
    */
   FEWDEE_EVENT_TICK = ALLEGRO_GET_EVENT_TYPE('F','e','w','D'),

   /**
    * An event sent whenever rendering is expected to be done. Handling it is
    * the expected way to draw stuff. The time elapsed since the last draw event
    * and the total time elapsed so far (both in seconds) are encoded in the
    * event "user parameters".
    *
    * See_Also: $(D deltaTime), $(D totalTime).
    */
   FEWDEE_EVENT_DRAW,
}


/**
 * Encodes a delta time (in seconds) and stores it in a given $(D
 * ALLEGRO_USER_EVENT) (assumed to be of type $(D FEWDEE_EVENT_TICK) or $(D
 * FEWDEE_EVENT_DRAW)).
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D deltaTime) member.
 */
public @property void deltaTime(ref ALLEGRO_USER_EVENT event, double deltaTime)
{
   event.data1 = cast(typeof(event.data1))
      (floor(deltaTime));
   event.data2 = cast(typeof(event.data2))
      ((deltaTime - event.data1) * 1_000_000_000);
}

/**
 * Decodes the delta time stored in a given ALLEGRO_USER_EVENT (assumed to be of
 * type FEWDEE_EVENT_TICK) and returns it (as the time in seconds elapsed during
 * that tick).
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an ALLEGRO_USER_EVENT had a deltaTime member.
 */
public @property double deltaTime(const ref ALLEGRO_USER_EVENT event)
{
   return event.data1 + (event.data2 / 1_000_000_000.0);
}

/**
 * Encodes a total time (in seconds) and stores it in a given $(D
 * ALLEGRO_USER_EVENT) (assumed to be of type $(D FEWDEE_EVENT_TICK) or $(D
 * FEWDEE_EVENT_DRAW)).
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D totalTime) member.
 */
public @property void totalTime(ref ALLEGRO_USER_EVENT event, double totalTime)
{
   event.data3 = cast(typeof(event.data3))
      (floor(totalTime));
   event.data4 = cast(typeof(event.data4))
      ((totalTime - event.data3) * 1_000_000_000);
}

/**
 * Decodes the total time stored in a given $(D ALLEGRO_USER_EVENT) (assumed to
 * be of type $(D FEWDEE_EVENT_TICK) or $(D FEWDEE_EVENT_DRAW)) and returns it
 * (in seconds).
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D totalTime) member.
 */
public @property double totalTime(const ref ALLEGRO_USER_EVENT event)
{
   return event.data3 + (event.data4 / 1_000_000_000.0);
}


// deltaTime()
unittest
{
   auto t = 123.456;
   ALLEGRO_USER_EVENT e;
   e.deltaTime = t;
   assert(abs(e.deltaTime - t) < 0.0001);
}


// totalTime()
unittest
{
   auto t = 0.987;
   ALLEGRO_USER_EVENT e;
   e.totalTime = t;
   assert(abs(e.totalTime - t) < 0.0001);
}
