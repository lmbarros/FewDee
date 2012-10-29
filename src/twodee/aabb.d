/**
 * Axis-aligned bounding box.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.aabb;


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
    * Checks if a given point is contained by this bounding box. The
    * "containment interval" is closed at the top and left, and opened at the
    * right and bottom.
    */
   public bool contains(float x, float y) const
   {
      return y >= top && y < bottom && x >= left && x < right;
   }

   /// The AABB's top, measured from the top of the screen.
   float top;

   /// The AABB's bottom, measured from the top of the screen.
   float bottom;

   /// The AABB's left side, measured from the left of the screen.
   float left;

   /// The AABB's right side, measured from the left of the screen.
   float right;
}


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
}
