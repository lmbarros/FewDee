/**
 * Axis-aligned bounding box.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.aabb;

import std.algorithm;
import std.conv;


/**
 * An axis-aligned 2D bounding box. Which makes it a bounding rectangle, I feel
 * obliged to add.
 */
struct AABB
{
   /// Constructor, for convenience.
   this(float top, float bottom, float left, float right)
   {
      this.top = top;
      this.bottom = bottom;
      this.left = left;
      this.right = right;
   }

   /**
    * Makes this $(D AABB) be the union of itself with the one passed as
    * parameter.
    */
   void unionWith(in AABB other)
   {
      top = min(this.top, other.top);
      bottom = max(this.bottom, other.bottom);
      left = min(this.left, other.left);
      right = max(this.right, other.right);
   }

   /**
    * Checks if a given point is contained by this bounding box. The
    * "containment interval" is closed at the top and left, and opened at the
    * right and bottom.
    */
   public bool contains(float x, float y) const
   {
      return y >= top && y < bottom && x >= left && x < right;
   }

   /// Returns a string representation of the AABB.
   public string toString() const
   {
      return "[" ~ to!string(top) ~ ", " ~ to!string(bottom)
         ~ ", " ~ to!string(left) ~ ", " ~ to!string(right) ~ "]";
   }

   /// The $(D AABB)'s top, measured from the top of the screen.
   public float top;

   /// The $(D AABB)'s bottom, measured from the top of the screen.
   public float bottom;

   /// The $(D AABB)'s left side, measured from the left of the screen.
   public float left;

   /// The $(D AABB)'s right side, measured from the left of the screen.
   public float right;

   // Tests AABB.contains()
   unittest
   {
      auto aabb = AABB(10.0, 30.0, 5.0, 40.0);

      assert(aabb.contains(5, 12));
      assert(!aabb.contains(0.0, 0.0));
      assert(!aabb.contains(50, 12));
      assert(aabb.contains(35.0, 29.0));
      assert(aabb.contains(10.0, 10.0)); // point along top segment
      assert(!aabb.contains(10.0, 30.0)); // point along bottom segment
      assert(aabb.contains(5.0, 20.0)); // point along left segment
      assert(!aabb.contains(5.0, 40.0)); // point along right segment

      // EmptyAABB doesn't contain any point
      assert(!EmptyAABB.contains(0.0, 0.0));
   }

   // Tests AABB.unionWith()
   unittest
   {
      auto aabb1 = AABB(-2, 10, 3, 8);
      const aabb2 = AABB(-1, 11, 4, 8);

      aabb1.unionWith(aabb2);
      assert(aabb1.top == -2);
      assert(aabb1.bottom == 11);
      assert(aabb1.left == 3);
      assert(aabb1.right == 8);

      const aabb3 = AABB(3, 4, 5, 7);
      aabb1.unionWith(aabb3);
      assert(aabb1.top == -2);
      assert(aabb1.bottom == 11);
      assert(aabb1.left == 3);
      assert(aabb1.right == 8);

      const aabb4 = AABB(-100, 100, -100, 100);
      aabb1.unionWith(aabb4);
      assert(aabb1.top == -100);
      assert(aabb1.bottom == 100);
      assert(aabb1.left == -100);
      assert(aabb1.right == 100);

      // Anything.unionWith(EmptyAABB) shall be equal to Anything
      aabb1.unionWith(EmptyAABB);
      assert(aabb1.top == -100);
      assert(aabb1.bottom == 100);
      assert(aabb1.left == -100);
      assert(aabb1.right == 100);
   }
}


/// An empty bounding box.
immutable EmptyAABB = AABB(float.nan, float.nan, float.nan, float.nan);
