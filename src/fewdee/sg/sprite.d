/**
 * A collection of same-sized bitmaps and a few additional bits.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.sprite;

import allegro5.allegro;
import std.conv;
import fewdee.aabb;
import fewdee.color;
import fewdee.sg.drawable;
import fewdee.internal.default_implementations;


/// A collection of same-sized bitmaps and a few additional bits.
public class Sprite: Drawable
{
   mixin ColorableDefaultImplementation;
   mixin PositionableDefaultImplementation!"dirtyAABB();";
   mixin RotatableDefaultImplementation!"dirtyAABB();";
   mixin ScalableDefaultImplementation!"dirtyAABB();";

   /**
    * Constructs the $(D Sprite), without adding any image to it.
    *
    * Parameters:
    *    width = The $(D Sprite) width, in pixels.
    *    height = The $(D Sprite) height, in pixels.
    *    centerX = The $(I x) coordinate of the $(D Sprite) center, in the local
    *       coordinate system.
    *    centerY = The $(I y) coordinate of the $(D Sprite) center, in the local
    *       coordinate system.
    */
   this(float width, float height, float centerX = 0.0, float centerY = 0.0)
   {
      _width = width;
      _height = height;
      _centerX = centerX;
      _centerY = centerY;
   }

   /**
    * Adds a bitmap to the $(D Sprite).
    *
    * Returns:
    *    The index of the added bitmap.
    */
   public final size_t addBitmap(ALLEGRO_BITMAP* bitmap)
   in
   {
      assert(bitmap !is null);
   }
   body
   {
      immutable bmpWidth = al_get_bitmap_width(bitmap);
      immutable bmpHeight = al_get_bitmap_height(bitmap);
      if (bmpWidth != _width || bmpHeight != _height)
      {
         throw new Exception(
            "Wrong sized sprite bitmap. Expected "
            ~ to!string(_width) ~ "x" ~ to!string(_height) ~ ", got "
            ~ to!string(bmpWidth) ~ "x" ~ to!string(bmpHeight));
      }

      _bitmaps ~= bitmap;

      return _bitmaps.length - 1;
   }

   /// The index of current bitmap.
   public final @property size_t currentIndex() const { return _currentIndex; }

   /// Ditto
   public final @property void currentIndex(size_t newIndex)
   {
      _currentIndex = newIndex;
   }

   /// The sprite width, in pixels.
   public final @property float width() const { return _width; }

   /// The sprite height, in pixels.
   public final @property float height() const { return _height; }

   /// Draws the current $(D Sprite) bitmap to the current target.
   public override void draw()
   in
   {
      assert(_currentIndex < _bitmaps.length);
   }
   body
   {
      immutable flags = 0;

      // All al_draw_*_bitmap() functions end up calling the "complex"
      // al_draw_tinted_scaled_rotated_bitmap(). So, we can always use this one
      // without worrying about performance. (In fact, we may be gaining some
      // performance, since we avoid a sequence of function calls that
      // eventually reach the one we are using.)
      al_draw_tinted_scaled_rotated_bitmap(
         _bitmaps[_currentIndex],
         color,
         _centerX,
         _centerY,
         x,
         y,
         scaleX,
         scaleY,
         rotation,
         flags);
   }

   // Inherit docs
   protected override void recomputeAABB(ref AABB aabb)
   {
      aabb = AABB(y - _centerY, y + height - _centerY,
                  x - _centerX, x + width - _centerX);
   }

   /// The index (into $(D _bitmaps)) of current bitmap.
   private size_t _currentIndex = 0;

   /// Sprite width, in pixels.
   private const float _width;

   /// Sprite height, in pixels.
   private const float _height;

   /// Sprite center along the $(I x) axis.
   private float _centerX;

   /// Sprite center along the $(I y) axis.
   private float _centerY;

   /// The bitmaps.
   private ALLEGRO_BITMAP*[] _bitmaps;
}
