/**
 * Helpers to create singletons, the most used design pattern (which is shame,
 * but anyway).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.internal.singleton;


/**
 * Mixin template to simplify the creation of a "singleton wrapper" for a given
 * class, using the low-lock idiom for fast, thread-safe access.
 *
 * This is not intended to be mixed in the class that would normally be made a
 * singleton. Instead, this shall be added to a class that will indirectly
 * provide access to the useful class. Like this:
 *
 * ---
 *
 * private class MySingletonImpl
 * {
 *    public void doSomething() { ... }
 * }
 *
 * public class MySingleton
 * {
 *    mixin LowLockSingleton!MySingletonImpl;
 * }
 *
 * ---
 *
 * Why this indirection? Because this way we can provide a handy $(D alias
 * instance this), so that we can call $(D MySingleton.doSomething()) instead of
 * the more verbose $(D MySingleton.instance.doSomething). As of DMD 2.062, the
 * $(D alias this) will not work if added directly to "the class that would
 * normally be a singleton".
 *
 * See_also:
 * http://davesdprogramming.wordpress.com/2013/05/06/low-lock-singletons
 *
 * Parameters:
 *    WrappedClass = The class that would normally be the singleton. You
 *      probably want it to be a $(D private) class.
 */
mixin template LowLockSingleton(WrappedClass)
{
   /// Returns the singleton instance.
   public static @property WrappedClass instance()
   {
      if (!_isInstantiated)
      {
         synchronized
         {
            if (_instance is null)
               _instance = new WrappedClass();
            _isInstantiated = true;
         }
      }
      return _instance;
   }

   /**
    * Destroys the singleton instance. Does nothing if it is not instantiated.
    *
    * It may seem strange to explicitly destroy a singleton instance, but it
    * comes handy when doing unit tests.
    */
   package static void destroyInstance()
   {
      synchronized
      {
         if (_instance !is null)
         {
            destroy(_instance);
            _instance = null;
            _isInstantiated = false;
         }
      }
   }

   /**
    * Checks if this singleton's instance is instantiated or not. This used by
    * the FewDee's core, to check if a singleton must be destroyed during engine
    * shutdown.
    */
   package @property bool isInstantiated()
   {
      bool isIt;

      synchronized
      {
         isIt = _instance !is null;
      }

      return isIt;
   }

   /// This saves us from typing $(D .instance) whenever we use the singleton.
   alias instance this;

   /// The constructor.
   private this() { }

   /**
    * Was the instance initialized yet? (This is thread local, and acts like a
    * "per thread cache" of the initialization state of $(D _instance).
    */
   private static bool _isInstantiated;

   /// The one and only instance.
   private __gshared WrappedClass _instance;
}
