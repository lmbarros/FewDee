/**
 * A collection of same-sized bitmaps and a few additional bits.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.sprite;

import allegro5.allegro;
import std.conv;
import twodee.aabb;
import twodee.positionable;
import twodee.sg.drawable;


/// A collection of same-sized bitmaps and a few additional bits.
class Sprite: Drawable, Positionable
{
   mixin PositionableDefaultImplementation!"recomputeAABB();";

   /**
    * Constructs the Sprite, without adding any image to it.
    *
    * Parameters:
    *    width = The Sprite width, in pixels.
    *    height = The Sprite height, in pixels.
    *    centerX = The x coordinate of the Sprite center, in the local
    *       coordinate system.
    *    centerY = The y coordinate of the Sprite center, in the local
    *       coordinate system.
    */
   this(float width, float height, float centerX = 0.0, float centerY = 0.0)
   {
      width_ = width;
      height_ = height;
      centerX_ = centerX;
      centerY_ = centerY;

      recomputeAABB();
   }

   /// Returns the node's bounding rectangle.
   public @property AABB aabb() const { return aabb_; }

   /**
    * Adds a bitmap to the Sprite.
    *
    * Returns: The index of the added bitmap.
    */
   public size_t addBitmap(ALLEGRO_BITMAP* bitmap)
   in
   {
      assert(bitmap !is null);
   }
   body
   {
      immutable bmpWidth = al_get_bitmap_width(bitmap);
      immutable bmpHeight = al_get_bitmap_height(bitmap);
      if (bmpWidth != width_ || bmpHeight != height_)
      {
         throw new Exception(
            "Wrong sized sprite bitmap. Expected "
            ~ to!string(width_) ~ "x" ~ to!string(height_) ~ ", got "
            ~ to!string(bmpWidth) ~ "x" ~ to!string(bmpHeight));
      }

      bitmaps_ ~= bitmap;

      return bitmaps_.length - 1;
   }

   /// The index of current bitmap.
   public @property size_t currentIndex() const { return currentIndex_; }

   /// The index of current bitmap.
   public @property void currentIndex(size_t newIndex)
   {
      currentIndex_ = newIndex;
   }

   /// The sprite width, in pixels.
   public @property float width() const { return width_; }

   /// The sprite height, in pixels.
   public @property float height() const { return height_; }

   /// Draws the current Sprite bitmap to the current target.
   public void draw()
   in
   {
      assert(currentIndex_ < bitmaps_.length);
   }
   body
   {
      immutable flags = 0;
      al_draw_bitmap(bitmaps_[currentIndex_], x, y, flags);
   }

   /// Recomputes the bounding box; stores it in aabb_.
   private void recomputeAABB()
   {
      aabb_ = AABB(y, y + height, x, x + width);
   }

   /// The index (into bitmaps_) of current bitmap.
   private size_t currentIndex_ = 0;

   /// Sprite width, in pixels.
   private float width_;

   /// Sprite height, in pixels.
   private float height_;

   /// Sprite center along the x axis.
   private float centerX_;

   /// Sprite center along the y axis.
   private float centerY_;

   /// The bounding box.
   private AABB aabb_;

   /// The bitmaps.
   private ALLEGRO_BITMAP*[] bitmaps_;
}
