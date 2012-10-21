/**
 * A collection of same-sized bitmaps and a few additional bits.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sprite;

import allegro5.allegro;
import std.conv;


/// A collection of same-sized bitmaps and a few additional bits.
class Sprite
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
   this(int width, int height, double centerX = 0.0, double centerY = 0.0)
   {
      width_ = width;
      height_ = height;
      centerX_ = centerX;
      centerY_ = centerY;
   }

   /// Destroys the Sprite. Destroys all bitmaps.
   ~this()
   {
      foreach(bitmap; bitmaps_)
         al_destroy_bitmap(bitmap);
   }

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

   /**
    * Draws current the Sprite bitmap to the current target.
    *
    * Parameters:
    *    x = The x coordinate where the bitmap will be drawn.
    *    y = The y coordinate where the bitmap will be drawn.
    *    flags = The flags. As of now, ALLEGRO_FLIP_HORIZONTAL and
    *       ALLEGRO_FLIP_VERTICAL are available.
    */
   void draw(double x, double y, int flags = 0)
   in
   {
      assert(currentIndex_ < bitmaps_.length);
   }
   body
   {
      al_draw_bitmap(bitmaps_[currentIndex_], x, y, flags);
   }

   /// The index (into bitmaps_) of current bitmap.
   size_t currentIndex_ = 0;

   /// Sprite width, in pixels.
   int width_;

   /// Sprite height, in pixels.
   int height_;

   /// Sprite center along the x axis.
   double centerX_;

   /// Sprite center along the y axis.
   double centerY_;

   /// The bitmaps.
   ALLEGRO_BITMAP*[] bitmaps_;
}
