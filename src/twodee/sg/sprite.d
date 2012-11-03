/**
 * A collection of same-sized bitmaps and a few additional bits.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.sprite;

import allegro5.allegro;
import std.conv;
import twodee.aabb;
import twodee.sg.drawable;


/// A collection of same-sized bitmaps and a few additional bits.
class Sprite: Drawable
{
   /**
    * Constructs the Sprite, without adding any image to it.
    *
    * Parameters:
    *    width = The Sprite width, in pixels.
    *    height = The Sprite height, in pixels.
    *    centerX = The Sprite center along the x axis.
    *    centerY = The Sprite center along the x axis.
    */
   this(int width, int height, float centerX = 0.0, float centerY = 0.0)
   {
      width_ = width;
      height_ = height;
      centerX_ = centerX;
      centerY_ = centerY;

      aabb_ = AABB(0, height, 0, width);
   }

   /// Destroys the Sprite. Destroys all bitmaps.
   ~this()
   {
      foreach(bitmap; bitmaps_)
         al_destroy_bitmap(bitmap);
   }

   /// Returns the node's bounding rectangle.
   public @property AABB aabb() const { return aabb_; }

   /**
    * Adds a bitmap to the Sprite.
    *
    * Returns: The index of the added bitmap.
    */
   size_t addBitmap(string fileName)
   {
      ALLEGRO_BITMAP* bitmap = al_load_bitmap(fileName.ptr);
      if (bitmap is null)
         throw new Exception("Error loading sprite bitmap '" ~ fileName ~ "'");

      immutable bmpWidth = al_get_bitmap_width(bitmap);
      immutable bmpHeight = al_get_bitmap_height(bitmap);
      if (bmpWidth != width_ || bmpHeight != height_)
      {
         throw new Exception(
            "Wrong sized sprite bitmap '" ~ fileName ~ "'. " ~ "Expected "
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

   /// The Sprite position, measured in pixels from the left of the screen.
   public @property void left(float newLeft)
   {
      left_ = newLeft;
      aabb_ = AABB(top, top + height, left, left + width);
   }

   /// The Sprite position, measured in pixels from the top of the screen.
   public @property void top(float newTop)
   {
      top_ = newTop;
      aabb_ = AABB(top, top + height, left, left + width);
   }

   /// The Sprite position, measured in pixels from the left of the screen.
   public @property float left() const { return left_; }

   /// The Sprite position, measured in pixels from the top of the screen.
   public @property float top() const { return top_; }

   /// The sprite width, in pixels.
   public @property float width() const { return width_; }

   /// The sprite height, in pixels.
   public @property float height() const { return height_; }

   /// Draws current the Sprite bitmap to the current target.
   void draw()
   in
   {
      assert(currentIndex_ < bitmaps_.length);
   }
   body
   {
      immutable flags = 0;
      al_draw_bitmap(bitmaps_[currentIndex_], left_, top_, flags);
   }

   /// The index (into bitmaps_) of current bitmap.
   size_t currentIndex_ = 0;

   /// The Sprite position, in pixels from the top of the screen.
   float top_;

   /// The Sprite position, in pixels from the left of the screen.
   float left_;

   /// Sprite width, in pixels.
   int width_;

   /// Sprite height, in pixels.
   int height_;

   /// Sprite center along the x axis.
   float centerX_;

   /// Sprite center along the y axis.
   float centerY_;

   /**
    * The bounding box.
    *
    * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    * xxxxxxx top, left, width and height can be deduced from this! Get rid of
    *         the redundancy (TODO).
    */
   AABB aabb_;

   /// The bitmaps.
   ALLEGRO_BITMAP*[] bitmaps_;
}
