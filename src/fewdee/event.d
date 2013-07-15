/**
 * FewDee events and event-related stuff.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event;

import std.math;
import allegro5.allegro;
import fewdee.sprite;


public enum
{
   /**
    * An event sent on every game engine tick. Handling it is the preferred way
    * to update the world state. The time elapsed during this tick and the total
    * time elapsed so far (both in seconds) are encoded in the event "user
    * parameters".
    *
    * See_also: $(D deltaTime), $(D totalTime).
    */
   FEWDEE_EVENT_TICK = ALLEGRO_GET_EVENT_TYPE('F','e','w','D'),

   /**
    * An event sent whenever rendering is expected to be done. Handling it is
    * the expected way to draw stuff. The time elapsed since the last draw event
    * and the total time elapsed so far (both in seconds) are encoded in the
    * event "user parameters".
    *
    * See_also: $(D deltaTime), $(D totalTime).
    */
   FEWDEE_EVENT_DRAW,

   /**
    * An event triggered when sprite animations reach certain frames. An ID
    * identifying which sprite animation happened and a reference to the sprite
    * generating the event are encoded in the event "user parameters".
    *
    * See_also: $(D spriteAnimationEventID), $(D sprite).
    */
   FEWDEE_EVENT_SPRITE_ANIMATION,
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

// Tests deltaTime()
unittest
{
   auto t = 123.456;
   ALLEGRO_USER_EVENT e;
   e.deltaTime = t;
   assert(abs(e.deltaTime - t) < 0.0001);
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

// Tests totalTime()
unittest
{
   auto t = 0.987;
   ALLEGRO_USER_EVENT e;
   e.totalTime = t;
   assert(abs(e.totalTime - t) < 0.0001);
}


/**
 * Encodes a sprite animation event ID and stores it in a given $(D
 * ALLEGRO_USER_EVENT), which is assumed to be of type $(D
 * FEWDEE_EVENT_SPRITE_ANIMATION)..
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D spriteAnimationEventID) member.
 */
public @property void spriteAnimationEventID(
   ref ALLEGRO_USER_EVENT event, int id)
{
   event.data1 = id;
}

/**
 * Decodes a sprite animation event ID stored in a given $(D ALLEGRO_USER_EVENT)
 * (assumed to be of type $(D FEWDEE_EVENT_SPRITE_ANIMATION)) and returns it.
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D spriteAnimationEventID) member.
 */
public @property int spriteAnimationEventID(const ref ALLEGRO_USER_EVENT event)
{
   return event.data1;
}

// Tests spriteAnimationEventID()
unittest
{
   import fewdee.strid;
   auto id = strID!"AnyID";

   ALLEGRO_USER_EVENT e;
   e.spriteAnimationEventID = id;
   assert(e.spriteAnimationEventID == strID!"AnyID");
}


/**
 * Encodes a reference to a $(D Sprite) and stores it in a given $(D
 * ALLEGRO_USER_EVENT), which is assumed to be of type $(D
 * FEWDEE_EVENT_SPRITE_ANIMATION)..
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D sprite) member.
 *
 * Low-level note that shouldn't affect FewDee users: If $(D s) is not $(D
 * null), this function adds $(D s) to the list of D's garbage collector roots,
 * and pins it to its position in memory (so that it can work nicely while
 * living in a C struct). Regardless of $(D s) being $(D null) or not, any
 * previously assigned $(D Sprite) is removed from the list of GC roots and is
 * unpinned. Therefore, passing $(D null) to this function is enough to
 * "cleanup" $(D event) after it has been used.
 */
public @property void sprite(ref ALLEGRO_USER_EVENT event, Sprite s)
{
   import core.stdc.stdint;
   import core.memory;

   auto currSprite = cast(void*)(event.data2);
   auto newSprite = cast(void*)(s);

   // Remove any currently stored sprite from the GC list of roots
   if (currSprite !is null)
   {
      GC.removeRoot(currSprite);
      GC.clrAttr(currSprite, GC.BlkAttr.NO_MOVE);
   }

   // Do the assignment proper
   event.data2 = cast(intptr_t)(newSprite);

   // Add the new sprite to the list of GC roots
   if (newSprite !is null)
   {
      GC.addRoot(newSprite);
      GC.setAttr(newSprite, GC.BlkAttr.NO_MOVE);
   }
}

/**
 * Decodes a reference to a $(D Sprite) stored in a given $(D
 * ALLEGRO_USER_EVENT) (assumed to be of type $(D
 * FEWDEE_EVENT_SPRITE_ANIMATION)) and returns it.
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D sprite) member.
 */
public @property Sprite sprite(const ref ALLEGRO_USER_EVENT event)
{
   return cast(Sprite)(cast(void*)(event.data2));
}

// Tests sprite()
unittest
{
   auto st = new SpriteTemplate();
   auto s = new Sprite(st);

   ALLEGRO_USER_EVENT e;
   e.sprite = s;
   assert(e.sprite is s);
}
