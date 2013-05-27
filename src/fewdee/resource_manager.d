/**
 * FewDee's Resource Manager and related definitions.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.resource_manager;

// import std.exception; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
import std.regex;
import allegro5.allegro;
import fewdee.engine;
import fewdee.aux.singleton;
import fewdee.llr.bitmap;
import fewdee.llr.font;


/**
 * Stores a collection of resources of the same type $(D T), indexed by string
 * keys. Has methods allowing to add, query and remove resources.
 */
private struct Resources(T)
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



/**
 * The real implementation of the Resource Manager. Users shall use this through
 * the $(D ResourceManager) class.
 *
 * TODO: Add some syntax to easily load a bunch of resources.
 */
private class ResourceManagerImpl
{
   private this()
   {
      Core.isResourceManagerInited = true;
   }


   package void finalize()
   {
      removeEverything();
   }

   /// Removes (and destroys) all resources of all types.
   public void removeEverything()
   {
      // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      // TODO: does this remove a resource with an empty string key?
      removeEverythingMatching("");
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
   }

   /// The Bitmap resources.
   public Resources!Bitmap bitmaps;

   /// The Font resources.
   public Resources!Font fonts;
}



/**
 * The Resource Manager singleton. Provides access to the one and only $(D
 * ResourceManagerImpl) instance.
 */
public class ResourceManager
{
   mixin LowLockSingleton!ResourceManagerImpl;
}
