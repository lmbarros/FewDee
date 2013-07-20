/**
 * FewDee events and event-related stuff.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.event;

import core.stdc.stdint;
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
    * the expected way to draw stuff. The time elapsed since the last draw
    * event, the total time elapsed so far, and the time elapsed since the last
    * tick event (all in seconds) are encoded in the event "user parameters".
    *
    * See_also: $(D deltaTime), $(D totalTime), $(D timeSinceTick).
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
   static if (event.data1.sizeof == float.sizeof)
   {
      const float asFloat = deltaTime;
      event.data1 = *(cast(intptr_t*)(&asFloat));
   }
   else if (event.data1.sizeof == double.sizeof)
   {
      event.data1 = *(cast(intptr_t*)(&deltaTime));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
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
   static if (event.data1.sizeof == float.sizeof)
   {
      return *(cast(float*)(&event.data1));
   }
   else if (event.data1.sizeof == double.sizeof)
   {
      return *(cast(double*)(&event.data1));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
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
   static if (event.data2.sizeof == float.sizeof)
   {
      const float asFloat = totalTime;
      event.data2 = *(cast(intptr_t*)(&asFloat));
   }
   else if (event.data2.sizeof == double.sizeof)
   {
      event.data2 = *(cast(intptr_t*)(&totalTime));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
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
   static if (event.data2.sizeof == float.sizeof)
   {
      return *(cast(float*)(&event.data2));
   }
   else if (event.data2.sizeof == double.sizeof)
   {
      return *(cast(double*)(&event.data2));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
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
 * Encodes time elapsed since the last tick event (in seconds) and stores it in
 * a given $(D ALLEGRO_USER_EVENT) (assumed to be of type $(D
 * FEWDEE_EVENT_DRAW)).
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D totalTime) member.
 */
public @property void
timeSinceTick(ref ALLEGRO_USER_EVENT event, double timeSinceTick)
{
   static if (event.data3.sizeof == float.sizeof)
   {
      const float asFloat = timeSinceTick;
      event.data3 = *(cast(intptr_t*)(&asFloat));
   }
   else if (event.data3.sizeof == double.sizeof)
   {
      event.data3 = *(cast(intptr_t*)(&totalTime));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
}

/**
 * Decodes the time (in seconds) elapsed since the last tick event stored in a
 * given $(D ALLEGRO_USER_EVENT) (assumed to be of type $(D FEWDEE_EVENT_DRAW))
 * and returns it.
 *
 * D's uniform function call syntax and properties allow to use this just as if
 * an $(D ALLEGRO_USER_EVENT) had a $(D totalTime) member.
 */
public @property double timeSinceTick(const ref ALLEGRO_USER_EVENT event)
{
   static if (event.data3.sizeof == float.sizeof)
   {
      return *(cast(float*)(&event.data3));
   }
   else if (event.data3.sizeof == double.sizeof)
   {
      return *(cast(double*)(&event.data3));
   }
   else
   {
      static assert(false, "Architecture not supported.");
   }
}

// Tests timeSinceTick()
unittest
{
   auto t = 1.123;
   ALLEGRO_USER_EVENT e;
   e.timeSinceTick = t;
   assert(abs(e.timeSinceTick - t) < 0.0001);
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
   event.data3 = id;
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
   return event.data3;
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

   auto currSprite = cast(void*)(event.data4);
   auto newSprite = cast(void*)(s);

   // Remove any currently stored sprite from the GC list of roots
   if (currSprite !is null)
   {
      GC.removeRoot(currSprite);
      GC.clrAttr(currSprite, GC.BlkAttr.NO_MOVE);
   }

   // Do the assignment proper
   event.data4 = cast(intptr_t)(newSprite);

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
   return cast(Sprite)(cast(void*)(event.data4));
}

// Tests sprite()
unittest
{
   auto st = new SpriteType();
   auto s = new Sprite(st);

   ALLEGRO_USER_EVENT e;
   e.sprite = s;
   assert(e.sprite is s);
}
