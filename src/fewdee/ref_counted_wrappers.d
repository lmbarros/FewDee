/**
 * Reference-counted wrappers on Allegro objects.
 *
 * The implementation of the reference-counting code is an adaptation of the
 * code in Phobos' std.typecons.
 *
 * Authors: Leandro Motta Barros.
 */

module fewdee.ref_counted_wrappers;

import core.stdc.stdlib;
import std.algorithm;
import std.exception;
import std.traits;
import allegro5.allegro;


/**
 * A mixin template providing the boilerplate code to create reference-counted
 * wrappers on Allegro objects.
 *
 * When the reference count goes to zero, the boilerplate code will call a $(D
 * dispose()) method, which must be defined by whoever mixes this in.
 *
 * Authors: This code is merely an adaptation of $(D std.typecons.RefCounted).
 */
mixin template RefCountedWrapper(T)
   if (isPointer!T && !is(T == class))
{
   /**
    * A structure containing the reference-counted data, the reference counter
    * itself and some related functions.
    */
   private struct RefCountedStore
   {
      /**
       * The structure storing the reference-counted data and the reference
       * counter itslef.
       */
      private struct StoreData
      {
         /// The reference-counted data.
         T _payload;

         /// The reference counter.
         size_t _count;
      }

      /// The reference-counted data and the counter itself.
      private StoreData* _store;

      /**
       * Allocates the reference-counted "store" from the heap and initializes
       * the reference-counter.
       */
      private void initialize()
      {
         _store = cast(StoreData*)enforce(malloc(StoreData.sizeof));
         _store._count = 1;
      }

      /**
       * Returns $(D true) if and only if the underlying store has been
       * allocated and initialized.
       */
      @property nothrow @safe
      bool isInitialized() const
      {
         return _store !is null;
      }

      /**
       * Returns underlying reference count if it is allocated and initialized
       * (a positive integer), and $(D 0) otherwise.
       */
      @property nothrow @safe
      size_t refCount() const
      {
         return isInitialized ? _store._count : 0;
      }

      /**
       * Makes sure the payload was properly initialized. Such a call is
       * typically inserted before using the payload.
       */
      void ensureInitialized()
      {
         if (!isInitialized)
            initialize();
      }
   }

   /**
    * The storage implementation structure, where reference-counted data and the
    * counter are stored.
    */
   RefCountedStore _refCounted;

   /// Returns storage implementation structure.
   @property nothrow @safe
   ref inout(RefCountedStore) refCountedStore() inout
   {
      return _refCounted;
   }

   /**
    * Constructor (postblit) that tracks the reference count appropriately. If
    * $(D !refCountedIsInitialized), does nothing.
    */
   this(this)
   {
      if (!_refCounted.isInitialized)
         return;
      ++_refCounted._store._count;
   }

   /**
    * Destructor that tracks the reference count appropriately. If $(D
    * !refCountedIsInitialized), does nothing. When the reference count goes
    * down to zero, calls $(D dispose()) to free the wrapped resource and $(D
    * free())s the reference-counted storage structure.
    */
    ~this()
    {
        if (!_refCounted.isInitialized)
           return;

        assert(_refCounted._store._count > 0);

        if (--_refCounted._store._count)
            return;

        // Reference counter is zero, deallocate
        this.dispose();
        free(_refCounted._store);
        _refCounted._store = null;
    }

    /// Assignment operator.
    void opAssign(typeof(this) rhs)
    {
       swap(_refCounted._store, rhs._refCounted._store);
    }

    /// Ditto
    void opAssign(T rhs)
    {
       _refCounted.ensureInitialized();
       move(rhs, _refCounted._store._payload);
    }

    /// Returns the wrapped resource.
    @property ref T refCountedPayload()
    {
       _refCounted.ensureInitialized();
       return _refCounted._store._payload;
    }

    // /// Ditto
    // @property nothrow @safe
    // ref inout(T) refCountedPayload() inout
    // {
    //    assert(_refCounted.isInitialized);
    //    return _refCounted._store._payload;
    // }

    /**
     * Allows to use the wrapper when the wrapped resource is expected. Calls
     * $(D refCountedEnsureInitialized()).
     */
    alias refCountedPayload this;
}


version (unittest)
{
   struct THING
   {
      private bool isValid = false;
      private int value = 0;
   }

   bool ThingIsValid(const THING* t)
   {
      return t.isValid;
   }

   void ThingSetIsValid(THING* t, bool v)
   {
      t.isValid = v;
   }

   int ThingValue(const THING* t)
   {
      return t.value;
   }

   void ThingSetValue(THING* t, int v)
   {
      t.value = v;
   }


   THING* CreateThing(int value)
   {
      THING* t = new THING;
      t.isValid = true;
      t.value = value;

      return t;
   }

   void DestroyThing(THING* t)
   {
      // Don't free the memory; in the tests, we want to be able to inspect the
      // THING state after it is destroyed.
      t.isValid = false;
   }


   struct Thing
   {
      mixin RefCountedWrapper!(THING*);

      public this(int value)
      {
         refCountedPayload = CreateThing(value);
      }

      private void dispose()
      {
         DestroyThing(refCountedPayload);
      }
   }
}


// Check if Things have the proper initialization status under different
// circumstances.
unittest
{
   Thing t1;
   assert(!t1._refCounted.isInitialized,
          "A default-initialized Thing should *not* be initialized.");

   auto t2 = Thing(123);
   assert(t2._refCounted.isInitialized,
          "A 'properly initialized' Thing should be initialized.");

   t1 = t2;
   assert(t1._refCounted.isInitialized,
          "After assignment, a previously uninitialized Thing should "
          "be initialized.");
}


// A Thing must be usable wherever a THING* is expected.
unittest
{
   auto t = Thing(0);
   assert(ThingIsValid(t));
   assert(ThingValue(t) == 0);

   ThingSetValue(t, 123);
   assert(ThingValue(t) == 123);

   // Accessing THING's members directly should also work
   assert(t.isValid);
   assert(t.value == 123);
}


// Check if the reference count behaves as expected
unittest
{
   auto t1 = Thing(171);
   assert (t1._refCounted._store._count == 1);

   auto t2 = t1;
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);
   assert (t1._refCounted._store == t2._refCounted._store,
           "These Things should shared the same store");

   void foo(Thing t)
   {
      assert (t._refCounted._store._count == 3);
      t.value *= 2;
   }

   foo(t1);
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);

   {
      auto t3 = t1;
      assert (t1._refCounted._store._count == 3);
      assert (t2._refCounted._store._count == 3);
      assert (t3._refCounted._store._count == 3);

      {
         auto t4 = t2;
         assert (t1._refCounted._store._count == 4);
         assert (t2._refCounted._store._count == 4);
         assert (t3._refCounted._store._count == 4);
         assert (t4._refCounted._store._count == 4);
      }

      assert (t1._refCounted._store._count == 3);
      assert (t2._refCounted._store._count == 3);
      assert (t3._refCounted._store._count == 3);
   }

   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);

   // Self-assignment shouldn't change the ref count
   t1 = t1;
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);

   t2 = t2;
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);

   // Ditto for "re-assignment"
   t1 = t2;
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);

   t2 = t1;
   assert (t1._refCounted._store._count == 2);
   assert (t2._refCounted._store._count == 2);
}


// Check if the Thing is disposed when the reference count goes to zero.
unittest
{
   THING* pt;

   {
      auto t = Thing(171);
      pt = t._refCounted._store._payload;
      assert(t.isValid);
      assert(pt.isValid);
   }

   assert(!pt.isValid,
          "Thing was not properly disposed after rec count zeroed.");
}


// Check if the Thing is disposed when the reference count goes to zero, take
// two.
unittest
{
   THING* pt;

   {
      auto t1 = Thing(171);
      pt = t1._refCounted._store._payload;
      assert(t1.isValid);
      assert(pt.isValid);

      auto t2 = t1;
      t2.value = 999;

      assert (t1._refCounted._store._count == 2);
      assert (t2._refCounted._store._count == 2);
   }

   assert(!pt.isValid,
          "Thing was not properly disposed after ref count zeroed.");
}


// Ensure that reference counted wrappers have reference semantics.
unittest
{
   auto t1 = Thing(987);
   assert(t1.value == 987);

   auto t2 = t1;
   assert(t2.value == 987);

   t2.value = 123;
   assert(t2.value == 123);
   assert(t1.value == 123);
}


// This is inspired in a test case in std.typecons.RefCounted. Something to do
// with "bug 4356".
unittest
{
   struct A
   {
      Thing t;
      this(int v)
      {
         t = Thing(v);
      }

      A copy()
      {
         auto another = this;
         return another;
      }
   }

   auto a = A(4);
   auto b = a.copy();
   assert(a.t._refCounted._store._count == 2, "BUG 4356 still unfixed");
   assert(a.t.value == b.t.value);
}


// Note: std.algorithm.swap() will not work with ref-counted objects
// (std.typecons.RefCounted doesn't work either if the wrapped resource is a
// pointer). Right now, I don't know enough D to fix this is a reasonable time,
// I'll leave this test disabled.
version (none)
{
   // std.algrithm.swap() must work with ref-counted stuff.
   unittest
   {
      auto t1 = Thing(123);
      auto t2 = Thing(456);
      swap(t1, t2);

      assert(t1._refCounted._store._count == 1);
      assert(t2._refCounted._store._count == 1);
      assert(t1.value == 456);
      assert(t2.value == 123);
      assert(false);
   }
}


// DMD used to have a bug related to struct destructors not being called on
// temporaries. Test this, just in case.
unittest
{
   Thing makeThing()
   {
      return Thing(333);
   }

   auto t = makeThing();
   assert(t._refCounted._store._count == 1);
   assert(t.value == 333);
}


//
// THE REAL WRAPPERS BEGIN HERE
//


// Doc-me! xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// postconds _handle !is null?
struct Bitmap
{
   mixin RefCountedWrapper!(ALLEGRO_BITMAP*);

   public this(uint width, uint height)
   {
      refCountedPayload = al_create_bitmap(width, height);
   }

   public this(string fileName)
   {
      refCountedPayload = al_load_bitmap(fileName.ptr);
   }

   private void dispose()
   {
      al_destroy_bitmap(refCountedPayload);
   }
}
