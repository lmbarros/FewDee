/**
 * Collections of stuff used throughout FewDee.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.internal.collections;


/**
 * A collection of elements bucketed according to some key. Each element has an
 * ID that can be used to remove it from the collection (without having to know
 * in which bucket it is, or even what is the value of the element). The
 * collection allows to iterate over all elements in a given bucket.
 *
 * Parameters:
 *    ValueType = The type of the collection elements.
 *    KeyType = The key used to define the buckets. If two elements are stored
 *       with the same key, they end up in the same buckets. If their keys are
 *       different, they go to different buckets.
 *    IDType = The type of the IDs of the collection elements.
 *    firstID = The ID of the first element added to the collection. Subsequent
 *       IDs will be generated by incrementing this value.
 */
public struct BucketedCollection(ValueType, KeyType, IDType, IDType firstID)
{
   /**
    * Adds an element to one of the internal buckets.
    *
    * Parameters:
    *    bucket = The bucket to which the element will be added.
    *    value = The element to add.
    *
    * Returns:
    *    An ID that can be later passed to $(D remove()) in order to remove the
    *    value just added.
    */
   public final IDType add(KeyType bucket, ValueType value)
   {
      const id = _nextID++;
      _elements[bucket][id] = value;
      return id;
   }

   /**
    * Removes an element from the collection.
    *
    * Parameters:
    *    id = The ID of the element to remove. If there is no element with this
    *       ID, nothing happens.
    *
    * Returns:
    *    $(D true) if the element was removed; $(D false) if not (which means
    *    that no element with the given ID was found).
    */
   public final bool remove(IDType id)
   {
      foreach(bucket, elements; _elements)
      {
         if (id in elements)
         {
            elements.remove(id);
            if (elements.length == 0)
               _elements.remove(bucket);
            return true;
         }
      }

      return false;
   }

   /**
    * Returns a bucket of elements.
    *
    * Parameters:
    *    bucket = The desired bucket.
    *
    * Returns:
    *    The requested bucket, or an empty data structure if no such bucket
    *    exist.  These are the elements, indexed by their IDs. You don't want to
    *    mess with the IDs. Use the elements only.
    *
    * See_also: bucketSize
    */
   public final inout(ValueType[IDType]) get(KeyType bucket) inout
   {
      auto b = bucket in _elements;
      if (b)
         return *b;
      else
         return (ValueType[IDType]).init;
   }

   /// Returns the number of elements in a given bucket.
   public final size_t bucketSize(KeyType bucket)
   {
      auto theBucket = bucket in _elements;
      if (theBucket)
         return theBucket.length;
      else
         return 0;
   }

   /// Returns the keys of the currently existing buckets.
   public final @property KeyType[] buckets() inout
   {
      return _elements.keys;
   }

   /// The next ID to be returned by $(D add()).
   private IDType _nextID = firstID;

   /**
    * The elements stored in the collection.
    *
    * $(D _elements[bucket]) yields the collection of elements in the $(D
    * bucket) bucket. The collection is a map in which each element is indexed
    * by its ID.
    */
   private ValueType[IDType][KeyType] _elements;
}


unittest
{
   enum Buckets { A, B, C, D }
   enum firstID = 678;

   alias BucketedCollection!(string, Buckets, int, firstID) strings;

   strings myStrings;

   // Initially, all buckets should be zero-sized.
   assert(myStrings.bucketSize(Buckets.A) == 0);
   assert(myStrings.bucketSize(Buckets.B) == 0);
   assert(myStrings.bucketSize(Buckets.C) == 0);
   assert(myStrings.bucketSize(Buckets.D) == 0);

   // Add some elements
   const id1 = myStrings.add(Buckets.B, "String 1");
   const id2 = myStrings.add(Buckets.D, "String 2");
   const id3 = myStrings.add(Buckets.B, "String 3");

   // Ensure the IDs are according to what is specified
   assert(id1 == firstID);
   assert(id2 == firstID + 1);
   assert(id3 == firstID + 2);

   // Now we should have some elements in some buckets
   assert(myStrings.bucketSize(Buckets.A) == 0);
   assert(myStrings.bucketSize(Buckets.B) == 2);
   assert(myStrings.bucketSize(Buckets.C) == 0);
   assert(myStrings.bucketSize(Buckets.D) == 1);

   // Test the 'buckets' property
   const buckets = myStrings.buckets;
   assert(buckets.length == 2);
   assert(buckets[0] == Buckets.B || buckets[0] == Buckets.D);
   assert(buckets[1] == Buckets.B || buckets[1] == Buckets.D);
   assert(buckets[0] != buckets[1]);

   // Check if we have the expected elements
   const bucketB = myStrings.get(Buckets.B);
   assert(bucketB.length == 2);
   assert(bucketB[id1] == "String 1");
   assert(bucketB[id3] == "String 3");

   auto bucketD = myStrings.get(Buckets.D);
   assert(bucketD.length == 1);
   assert(bucketD[id2] == "String 2");

   // Now, remove an element and check everything again
   myStrings.remove(id3);

   assert(myStrings.bucketSize(Buckets.A) == 0);
   assert(myStrings.bucketSize(Buckets.B) == 1);
   assert(myStrings.bucketSize(Buckets.C) == 0);
   assert(myStrings.bucketSize(Buckets.D) == 1);

   assert(myStrings.get(Buckets.B)[id1] == "String 1");
   assert(myStrings.get(Buckets.D)[id2] == "String 2");

   // Now, remove the remaining two elements, re-check
   myStrings.remove(id1);
   myStrings.remove(id2);

   assert(myStrings.bucketSize(Buckets.A) == 0);
   assert(myStrings.bucketSize(Buckets.B) == 0);
   assert(myStrings.bucketSize(Buckets.C) == 0);
   assert(myStrings.bucketSize(Buckets.D) == 0);
}


/**
 * A bidirectional associative array.
 *
 * Maps one type to another and another to one, so to speak.
 *
 * TODO: Should I worry about things like $(D const)s, $(D inout)s here? Right
 *    now I am using this only with built-in types, so I guess I am OK. Sloppy,
 *    but OK.
 */
public struct BiMap(TypeA, TypeB)
{
   /// Gets a mapping.
   public final TypeB opIndex(TypeA valueA) inout
   {
      return _aToB[valueA];
   }

   /// Ditto.
   public final TypeA opIndex(TypeB valueB) inout
   {
      return _bToA[valueB];
   }

   /// Adds a mapping.
   public final TypeA opIndexAssign(TypeA valueA, TypeB valueB)
   {
      const oldA = valueB in _bToA;
      const oldB = valueA in _aToB;

      if (oldA)
         _aToB.remove(*oldA);

      if (oldB)
         _bToA.remove(*oldB);

      _aToB[valueA] = valueB;
      _bToA[valueB] = valueA;

      return valueA;
   }

   /// Ditto.
   public final TypeB opIndexAssign(TypeB valueB, TypeA valueA)
   {
      const oldA = valueB in _bToA;
      const oldB = valueA in _aToB;

      if (oldA)
         _aToB.remove(*oldA);

      if (oldB)
         _bToA.remove(*oldB);

      _aToB[valueA] = valueB;
      _bToA[valueB] = valueA;

      return valueB;
   }

   /// Clears all the mappings.
   public final void clear()
   {
      _aToB = typeof(_aToB).init;
      _bToA = typeof(_bToA).init;
   }

   /// The number of mappings stored.
   public final @property size_t length() inout
   in
   {
      assert(_bToA.length == _aToB.length);
   }
   body
   {
      return _aToB.length;
   }

   /// $(D in) operator.
   public TypeA* opBinaryRight(string op: "in")(TypeB valueB)
   {
      return valueB in _bToA;
   }

   /// Ditto.
   public TypeB* opBinaryRight(string op: "in")(TypeA valueA)
   {
      return valueA in _aToB;
   }

   /// Maps $(D TypeA)s to $(D TypeB)s.
   private TypeB[TypeA] _aToB;

   /// Maps $(D TypeB)s to $(D TypeA)s.
   private TypeA[TypeB] _bToA;
}

unittest
{
   BiMap!(int, string) bm;

   // Empty at the beginning
   assert(bm.length == 0);

   // Add some mappings
   bm[1] = "one";
   bm["two"] = 2;

   assert(bm.length == 2);

   // Check them
   assert(bm[1] == "one");
   assert(bm["one"] == 1);
   assert(bm[2] == "two");
   assert(bm["two"] == 2);

   // Overwrite one mapping
   bm[2] = "dois";
   assert(bm.length == 2);

   // Re-check mappings
   assert(bm[1] == "one");
   assert(bm["one"] == 1);
   assert(bm[2] == "dois");
   assert(bm["dois"] == 2);

   // Clear all mappings
   bm.clear();
   assert(bm.length == 0);
}