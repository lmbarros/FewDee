/**
 * FewDee's Resource Manager and related definitions.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.resource_manager;

import std.regex;
import allegro5.allegro;
import fewdee.core;
import fewdee.internal.singleton;
import fewdee.llr.audio_sample;
import fewdee.llr.audio_stream;
import fewdee.llr.bitmap;
import fewdee.llr.font;


/**
 * Stores a collection of resources of the same type $(D T), indexed by string
 * keys. Has methods allowing to add, query and remove resources.
 */
private struct ResourceCollection(T)
   if (is(T: fewdee.llr.low_level_resource.LowLevelResource))
{
   /**
    * Adds a given resource to the collection.
    *
    * Parameters:
    *    key = The key to which the resource will be associated. An exception is
    *       thrown if a resource with this key already exists.
    *    res = The resource to add.
    */
   public void add(in string key, T res)
   {
      if (key in _resources)
      {
         throw new Exception(
            "There is already a " ~ T.stringof ~ " with key '"~ key ~ "'.");
      }

      _resources[key] = res;
   }

   /**
    * Destroys a resource with a given key and removes it from the
    * collection. If there is no resource with the requested key, nothing
    * happens.
    *
    * Parameters:
    *    key = The key of the resource to will be associated. An exception is
    *       thrown if a resource with this key already exists.
    *    res = The resource to add.
    */
   public void remove(in string key)
   {
      auto res = key in _resources;
      if (res)
      {
         res.free();
         _resources.remove(key);
      }
   }

   /**
    * Returns a reference to the resource with the given key (or $(D null) if no
    * such resource exists).
    */
   public inout(T) opIndex(in string key) inout
   {
      if (auto r = key in _resources)
         return *r;
      else
         return null;
   }

   /**
    * Removes (and destroys) all resources with keys matching a given regular
    * expression.
    */
   public void removeMatching(in string regex)
   {
      auto re = std.regex.regex(regex);
      removeMatching(re);
   }

   /**
    * Removes (and destroys) all resources with keys matching a given regular
    * expression.
    */
   public void removeMatching(Regex!char regex)
   {
      foreach (key; _resources.keys)
      {
         if (match(key, regex))
            remove(key);
      }
   }

   /// The resources are stored here.
   private T[string] _resources;
}


/// A regex matching everything.
private enum regexMatchingEverything = "";


/**
 * The real implementation of the Resource Manager. Users shall use this through
 * the $(D ResourceManager) class.
 *
 * TODO: Add some syntax to easily load a bunch of resources.
 */
private class ResourceManagerImpl
{
   /// Constructs the Resource Manager.
   private this()
   {
      Core.isResourceManagerInited = true;
   }

   /**
    * Finalize the Resource Manager, destroying all resources it currently owns.
    */
   package void finalize()
   {
      removeEverything();
   }

   /// Removes (and destroys) all resources of all types.
   public void removeEverything()
   {
      removeEverythingMatching(regexMatchingEverything);
   }

   /**
    * Removes (and destroys) all resources (of all types) with keys matching a
    * given regular expression.
    */
   public void removeEverythingMatching(in string regex)
   {
      auto re = std.regex.regex(regex);
      removeEverythingMatching(re);
   }

   /**
    * Removes (and destroys) all resources (of all types) with keys matching a
    * given regular expression.
    */
   public void removeEverythingMatching(Regex!char regex)
   {
      bitmaps.removeMatching(regex);
      fonts.removeMatching(regex);
      samples.removeMatching(regex);
      streams.removeMatching(regex);
   }

   /// The Bitmap resources.
   public ResourceCollection!Bitmap bitmaps;

   /// The Font resources.
   public ResourceCollection!Font fonts;

   /// The Audio Sample resources.
   public ResourceCollection!AudioSample samples;

   /// The Audio Stream resources.
   public ResourceCollection!AudioStream streams;
}



/**
 * The Resource Manager singleton. Provides access to the one and only $(D
 * ResourceManagerImpl) instance.
 */
public class ResourceManager
{
   mixin LowLockSingleton!ResourceManagerImpl;
}



//
// Unit tests
//

version (unittest)
{
   private immutable fakeResourceBoilerplate = `
      import fewdee.llr.low_level_resource;
      bool[string] destroyed;

      class FakeResource: LowLevelResource
      {
         this(string data) { _data = data; }
         public void free() { destroyed[_data] = true; }
         private string _data;
      }`;
} // version(unittest)


// ResourceCollection.add()
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;
   assert(rc._resources.length == 0);

   rc.add("a", new FakeResource("a"));
   assert(rc._resources.length == 1);

   rc.add("b", new FakeResource("b"));
   rc.add("c", new FakeResource("c"));
   assert(rc._resources.length == 3);
}

// ResourceCollection.remove()
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;

   rc.add("a", new FakeResource("a"));
   rc.add("b", new FakeResource("b"));
   rc.add("c", new FakeResource("c"));
   rc.add("d", new FakeResource("d"));
   rc.add("e", new FakeResource("e"));

   assert(rc._resources.length == 5);
   assert(destroyed.length == 0);

   rc.remove("b");
   assert(rc._resources.length == 4);
   assert(destroyed.length == 1);
   assert("b" in destroyed);

   rc.remove("c");
   rc.remove("c"); // remove twice; must work
   assert(rc._resources.length == 3);
   assert(destroyed.length == 2);
   assert("c" in destroyed);

   rc.remove("z"); // remove nonexistent resource; must be no-op
   assert(rc._resources.length == 3);
   assert(destroyed.length == 2);

   rc.remove("e");
   assert(rc._resources.length == 2);
   assert(destroyed.length == 3);
   assert("e" in destroyed);
}


// ResourceCollection.opIndex()
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;
   auto a = new FakeResource("a");
   auto b = new FakeResource("b");
   auto c = new FakeResource("c");

   rc.add("a", a);
   rc.add("b", b);
   rc.add("c", c);

   assert(rc["a"] == a);
   assert(rc["b"] == b);
   assert(rc["c"] == c);
}

// ResourceCollection.removeMatching(string)
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;
   rc.add("a-1", new FakeResource("a-1"));
   rc.add("a-2", new FakeResource("a-2"));
   rc.add("a-3", new FakeResource("a-3"));
   rc.add("b-1", new FakeResource("b-1"));
   rc.add("b-2", new FakeResource("b-2"));
   rc.add("b-3", new FakeResource("b-3"));
   rc.add("c-1", new FakeResource("c-1"));
   rc.add("c-2", new FakeResource("c-2"));
   rc.add("c-3", new FakeResource("c-3"));

   assert(rc._resources.length == 9);
   assert(destroyed.length == 0);

   rc.removeMatching("z"); // shall not match anything
   assert(rc._resources.length == 9);
   assert(destroyed.length == 0);

   rc.removeMatching("[abc]-2");
   assert(rc._resources.length == 6);
   assert(destroyed.length == 3);
   assert("a-2" in destroyed);
   assert("b-2" in destroyed);
   assert("c-2" in destroyed);

   rc.removeMatching("a-");
   assert(rc._resources.length == 4);
   assert(destroyed.length == 5);
   assert("a-1" in destroyed);
   assert("a-2" in destroyed); // was there already, but anyway
   assert("a-3" in destroyed);
}


// ResourceCollection.removeMatching(Regex!char)
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;
   rc.add("a-1", new FakeResource("a-1"));
   rc.add("a-2", new FakeResource("a-2"));
   rc.add("a-3", new FakeResource("a-3"));
   rc.add("b-1", new FakeResource("b-1"));
   rc.add("b-2", new FakeResource("b-2"));
   rc.add("b-3", new FakeResource("b-3"));
   rc.add("c-1", new FakeResource("c-1"));
   rc.add("c-2", new FakeResource("c-2"));
   rc.add("c-3", new FakeResource("c-3"));

   assert(rc._resources.length == 9);
   assert(destroyed.length == 0);

   rc.removeMatching(std.regex.regex("z")); // shall not match anything
   assert(rc._resources.length == 9);
   assert(destroyed.length == 0);

   rc.removeMatching(std.regex.regex("[abc]-2"));
   assert(rc._resources.length == 6);
   assert(destroyed.length == 3);
   assert("a-2" in destroyed);
   assert("b-2" in destroyed);
   assert("c-2" in destroyed);

   rc.removeMatching(std.regex.regex("a-"));
   assert(rc._resources.length == 4);
   assert(destroyed.length == 5);
   assert("a-1" in destroyed);
   assert("a-2" in destroyed); // was there already, but anyway
   assert("a-3" in destroyed);
}


// ResourceCollection.removeMatching(regexMatchingEverything)
unittest
{
   mixin(fakeResourceBoilerplate);

   ResourceCollection!FakeResource rc;
   rc.add("a-1", new FakeResource("a-1"));
   rc.add("a-2", new FakeResource("a-2"));
   rc.add("a-3", new FakeResource("a-3"));
   rc.add("b-1", new FakeResource("b-1"));
   rc.add("b-2", new FakeResource("b-2"));
   rc.add("b-3", new FakeResource("b-3"));
   rc.add("c-1", new FakeResource("c-1"));
   rc.add("c-2", new FakeResource("c-2"));
   rc.add("c-3", new FakeResource("c-3"));
   rc.add("", new FakeResource("")); // empty string as key

   assert(rc._resources.length == 10);
   assert(destroyed.length == 0);

   rc.removeMatching(regexMatchingEverything);
   assert(rc._resources.length == 0);
   assert(destroyed.length == 10);

   assert("a-1" in destroyed);
   assert("b-1" in destroyed);
   assert("c-1" in destroyed);
   assert("a-2" in destroyed);
   assert("b-2" in destroyed);
   assert("c-2" in destroyed);
   assert("a-3" in destroyed);
   assert("b-3" in destroyed);
   assert("c-3" in destroyed);
   assert("" in destroyed);
}

version (unittest)
{
   // During unit test execution, the Allegro modules necessary to load real
   // data are not loaded, so we use these dummies. (Yes, I tried to load the
   // Allegro modules, but for some reason this didn't work.) Notice that the
   // call to the super() will fail (no real data being loaded), so we simply
   // catch and pretend that everything went fine.
   private immutable fakeLowLevelResourcesBoilerplate = `
      class FakeFont: Font
      {
         this()
         {
            try
            {
               super("foo.ttf", 10);
            }
            catch(Throwable)
            {
               // Nothing here
            }
         }
         public override void free() { }
      }

      class FakeAudioSample: AudioSample
      {
         this()
         {
            try
            {
               super("foo.ogg");
            }
            catch(Throwable)
            {
               // Nothing here
            }
         }
         public override void free() { }
      }

      class FakeAudioStream: AudioStream
      {
         this()
         {
            try
            {
               super("foo.ogg");
            }
            catch(Throwable)
            {
               // Nothing here
            }
         }
         public override void free() { }
      }
   `;
} // version(unittest)


// ResourceManagerImpl.removeEverything()
unittest
{
   mixin(fakeLowLevelResourcesBoilerplate);

   // Being able to instantiate what should be a singleton in a unit test is
   // weird, but useful nevertheless
   scope rm = new ResourceManagerImpl();
   assert(rm.bitmaps._resources.length == 0);
   assert(rm.fonts._resources.length == 0);
   assert(rm.samples._resources.length == 0);
   assert(rm.streams._resources.length == 0);

   rm.bitmaps.add("a", new Bitmap("data/logo.png"));
   rm.bitmaps.add("b", new Bitmap("data/logo.png"));
   rm.bitmaps.add("c", new Bitmap("data/logo.png"));
   rm.bitmaps.add("", new Bitmap("data/logo.png")); // empty string as key
   assert(rm.bitmaps._resources.length == 4);

   rm.fonts.add("a", new FakeFont);
   rm.fonts.add("b", new FakeFont);
   rm.fonts.add("c", new FakeFont);
   assert(rm.fonts._resources.length == 3);

   rm.samples.add("a", new FakeAudioSample);
   rm.samples.add("b", new FakeAudioSample);
   rm.samples.add("c", new FakeAudioSample);
   rm.samples.add("d", new FakeAudioSample);
   rm.samples.add("e", new FakeAudioSample);
   assert(rm.samples._resources.length == 5);

   rm.streams.add("a", new FakeAudioStream);
   rm.streams.add("b", new FakeAudioStream);
   assert(rm.streams._resources.length == 2);

   rm.removeEverything();

   // TODO: Can't I make some compile-time magic to ensure that all
   // ResourceCollection!T members are tested? (But then, I could use the same
   // magic in the implementation of removeEverything()).
   assert(rm.bitmaps._resources.length == 0);
   assert(rm.fonts._resources.length == 0);
   assert(rm.samples._resources.length == 0);
   assert(rm.streams._resources.length == 0);
}


// ResourceManagerImpl.removeEverythingMatching(string)
unittest
{
   mixin(fakeLowLevelResourcesBoilerplate);

   // Being able to instantiate what should be a singleton in a unit test is
   // weird, but useful nevertheless
   scope rm = new ResourceManagerImpl();

   rm.bitmaps.add("1-a", new Bitmap("data/logo.png"));
   rm.bitmaps.add("1-b", new Bitmap("data/logo.png"));
   rm.bitmaps.add("2-a", new Bitmap("data/logo.png"));
   rm.bitmaps.add("3-a", new Bitmap("data/logo.png"));
   assert(rm.bitmaps._resources.length == 4);

   rm.fonts.add("1-a", new FakeFont);
   rm.fonts.add("2-a", new FakeFont);
   rm.fonts.add("2-b", new FakeFont);
   assert(rm.fonts._resources.length == 3);

   rm.samples.add("1-a", new FakeAudioSample);
   rm.samples.add("2-a", new FakeAudioSample);
   rm.samples.add("2-b", new FakeAudioSample);
   rm.samples.add("2-c", new FakeAudioSample);
   rm.samples.add("3-a", new FakeAudioSample);
   assert(rm.samples._resources.length == 5);

   rm.streams.add("1-a", new FakeAudioStream);
   rm.streams.add("2-a", new FakeAudioStream);
   assert(rm.streams._resources.length == 2);

   // First batch of removals
   rm.removeEverythingMatching("3-");
   assert(rm.bitmaps._resources.length == 3);
   assert(rm.fonts._resources.length == 3);
   assert(rm.samples._resources.length == 4);
   assert(rm.streams._resources.length == 2);

   // Second batch of removals
   rm.removeEverythingMatching("-b");
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 3);
   assert(rm.streams._resources.length == 2);

   // Third batch of removals: remove nothing
   rm.removeEverythingMatching("xxx");
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 3);
   assert(rm.streams._resources.length == 2);

   // Fourth and last batch of removals
   rm.removeEverythingMatching("-c");
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 2);
   assert(rm.streams._resources.length == 2);
}

// ResourceManagerImpl.removeEverythingMatching(Regex!char)
unittest
{
   mixin(fakeLowLevelResourcesBoilerplate);

   // Being able to instantiate what should be a singleton in a unit test is
   // weird, but useful nevertheless
   scope rm = new ResourceManagerImpl();

   rm.bitmaps.add("1-a", new Bitmap("data/logo.png"));
   rm.bitmaps.add("1-b", new Bitmap("data/logo.png"));
   rm.bitmaps.add("2-a", new Bitmap("data/logo.png"));
   rm.bitmaps.add("3-a", new Bitmap("data/logo.png"));
   assert(rm.bitmaps._resources.length == 4);

   rm.fonts.add("1-a", new FakeFont);
   rm.fonts.add("2-a", new FakeFont);
   rm.fonts.add("2-b", new FakeFont);
   assert(rm.fonts._resources.length == 3);

   rm.samples.add("1-a", new FakeAudioSample);
   rm.samples.add("2-a", new FakeAudioSample);
   rm.samples.add("2-b", new FakeAudioSample);
   rm.samples.add("2-c", new FakeAudioSample);
   rm.samples.add("3-a", new FakeAudioSample);
   assert(rm.samples._resources.length == 5);

   rm.streams.add("1-a", new FakeAudioStream);
   rm.streams.add("2-a", new FakeAudioStream);
   assert(rm.streams._resources.length == 2);

   // First batch of removals
   rm.removeEverythingMatching(std.regex.regex("3-"));
   assert(rm.bitmaps._resources.length == 3);
   assert(rm.fonts._resources.length == 3);
   assert(rm.samples._resources.length == 4);
   assert(rm.streams._resources.length == 2);

   // Second batch of removals
   rm.removeEverythingMatching(std.regex.regex("-b"));
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 3);
   assert(rm.streams._resources.length == 2);

   // Third batch of removals: remove nothing
   rm.removeEverythingMatching(std.regex.regex("xxx"));
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 3);
   assert(rm.streams._resources.length == 2);

   // Fourth and last batch of removals
   rm.removeEverythingMatching(std.regex.regex("-c"));
   assert(rm.bitmaps._resources.length == 2);
   assert(rm.fonts._resources.length == 2);
   assert(rm.samples._resources.length == 2);
   assert(rm.streams._resources.length == 2);
}
