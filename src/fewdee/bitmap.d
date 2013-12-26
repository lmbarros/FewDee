/**
 * A low-level Bitmap resource.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.bitmap;

import std.exception;
import std.string;
import allegro5.allegro;
import fewdee.allegro_manager;
import fewdee.engine;
import fewdee.low_level_resource;


/**
 * A low-level bitmap resource; encapsulates an $(D ALLEGRO_BITMAP*).
 *
 * Bitmaps are created using the flags set in the $(D Engine).
 */
public class Bitmap: LowLevelResource
{
   /**
    * Creates a $(D Bitmap) with the given dimensions. Throws if the bitmap
    * cannot be created.
    *
    * Parameters:
    *    width = The bitmap width, in pixels.
    *    height = The bitmap height, in pixels.
    */
   this(uint width, uint height)
   {
      Engine.applyBitmapCreationFlags();
      _bitmap = al_create_bitmap(width, height);
      enforce(_bitmap !is null, "Couldn't create bitmap");
   }

   /**
    * Creates a Bitmap, reading its contents from a given file.
    *
    * Parameters:
    *    path = The path to the bitmap image file.
    */
   this(in string path)
   {
      AllegroManager.initImageIO();
      Engine.applyBitmapCreationFlags();
      _bitmap = al_load_bitmap(path.toStringz);
      enforce(_bitmap !is null, "Couldn't load bitmap from '" ~ path ~ "'");
   }

   /// Frees all resources used by the Bitmap.
   public void free()
   {
      al_destroy_bitmap(_bitmap);
      _bitmap = null;
   }

   /// The bitmap width, in pixels.
   public final @property int width()
   {
      return al_get_bitmap_width(_bitmap);
   }

   /// The bitmap height, in pixels.
   public final @property int height()
   {
      return al_get_bitmap_height(_bitmap);
   }

   /**
    * Draw the bitmap to the current render target (normally, the default
    * screen).
    *
    * Different overloads are provided, each one accepting arguments in
    * different orders, or in a slightly different fashion.
    *
    * Parameters:
    *   x = The horizontal coordinate of the point where the bitmap will be
    *      drawn. This is in pixels, in the target coordinate system.
    *   y = The vertical coordinate of the point where the bitmap will be
    *      drawn. This is in pixels, in the target coordinate system.
    *   tint = The colors of the bitmap are multiplied by this one.
    *   rotation = The angle of rotation, in radians. Rotation is measured in
    *      the clockwise direction.
    *   scaleX = The scale factor to apply in the horizontal axis.
    *   scaleY = The scale factor to apply in the vertical axis.
    *   centerX = The horizontal coordinate of the bitmap center, around which
    *      scale and rotation will be performed (and also the point that will be
    *      drawn at the ($(D x), $(D y)) coordinates passed as parameter).
    *   centerY = The vertical coordinate of the bitmap center, around which
    *      scale and rotation will be performed (and also the point that will be
    *      drawn at the ($(D x), $(D y)) coordinates passed as parameter).
    *   height = The width of the region to draw, in pixels.
    *   flags = The drawing flags, passed directly to Allegro. As of this
    *      writing, $(D flags) must be a combination of $(D
    *      ALLEGRO_FLIP_HORIZONTAL) and $(D ALLEGRO_FLIP_VERTICAL).
    */
   public final void draw(float x, float y, int flags = 0)
   {
      // Could have used al_draw_bitmap() here for somewhat simpler code. As of
      // now (December, 2014), however, the simpler Allegro functions simply
      // call the more complex ones, so calling this one can actually be
      // marginally faster, since some function calls are spared. (Or is the
      // average linker/optimizer nowadays smarter than I think?)
      al_draw_tinted_scaled_rotated_bitmap(
         _bitmap,
         al_map_rgba_f(1.0, 1.0, 1.0, 1.0),
         0.0, 0.0,
         x, y,
         1.0, 1.0,
         0.0,
         flags);
   }

   /// Ditto
   public final void draw(float x, float y,
                          float[4] tint,
                          float rotation = 0.0,
                          float scaleX = 1.0, float scaleY = 1.0,
                          float centerX = 0.0, float centerY = 0.0,
                          int flags = 0)
   {
      al_draw_tinted_scaled_rotated_bitmap(
         _bitmap,
         al_map_rgba_f(tint[0], tint[1], tint[2], tint[3]),
         centerX, centerY,
         x, y,
         scaleX, scaleY,
         rotation,
         flags);
   }

   // Ditto
   public final void draw(float x, float y,
                          float rotation,
                          float scaleX = 1.0, float scaleY = 1.0,
                          float[4] tint = [ 1.0, 1.0, 1.0, 1.0 ],
                          float centerX = 0.0, float centerY = 0.0,
                          int flags = 0)
   {
      al_draw_tinted_scaled_rotated_bitmap(
         _bitmap,
         al_map_rgba_f(tint[0], tint[1], tint[2], tint[3]),
         centerX, centerY,
         x, y,
         scaleX, scaleY,
         rotation,
         flags);
   }

   /**
    * Draw a region of the bitmap to the current render target (normally, the
    * default screen).
    *
    * Different overloads are provided, each one accepting arguments in
    * different orders, or in a slightly different fashion.
    *
    * Parameters:
    *   x = The horizontal coordinate of the point where the bitmap will be
    *      drawn. This is in pixels, in the target coordinate system.
    *   y = The vertical coordinate of the point where the bitmap will be
    *      drawn. This is in pixels, in the target coordinate system.
    *   tint = The colors of the bitmap are multiplied by this one.
    *   rotation = The angle of rotation, in radians. Rotation is measured in
    *      the clockwise direction.
    *   scaleX = The scale factor to apply in the horizontal axis.
    *   scaleY = The scale factor to apply in the vertical axis.
    *   centerX = The horizontal coordinate of the bitmap center, around which
    *      scale and rotation will be performed (and also the point that will be
    *      drawn at the ($(D x), $(D y)) coordinates passed as parameter).
    *   centerY = The vertical coordinate of the bitmap center, around which
    *      scale and rotation will be performed (and also the point that will be
    *      drawn at the ($(D x), $(D y)) coordinates passed as parameter).
    *   srcX = The horizontal coordinate of the top-left corner of the region to
    *      draw, in pixels.
    *   srcY = The vertical coordinate of the top-left corner of the region to
    *      draw, in pixels.
    *   width = The width of the region to draw, in pixels.
    *   height = The width of the region to draw, in pixels.
    *   flags = The drawing flags, passed directly to Allegro. As of this
    *      writing, $(D flags) must be a combination of $(D
    *      ALLEGRO_FLIP_HORIZONTAL) and $(D ALLEGRO_FLIP_VERTICAL).
    */
   public final void drawRegion(float x, float y, float srcX, float srcY,
                                float width, float height, int flags = 0)
   {
      // Could have used al_draw_bitmap_region() here for somewhat simpler
      // code. As of now (December, 2014), however, the simpler Allegro
      // functions simply call the more complex ones, so calling this one can
      // actually be marginally faster, since some function calls are
      // spared. (Or is the average linker/optimizer nowadays smarter than I
      // think?)
      al_draw_tinted_scaled_rotated_bitmap_region(
         _bitmap,
         srcX, srcY, width, height,
         al_map_rgba_f(1.0, 1.0, 1.0, 1.0),
         0.0, 0.0,
         x, y,
         1.0, 1.0,
         0.0,
         flags);
   }

   /// Ditto
   public final void drawRegion(float x, float y,
                                float srcX, float srcY,
                                float width, float height,
                                float[4] tint,
                                float rotation = 0.0,
                                float scaleX = 1.0, float scaleY = 1.0,
                                float centerX = 0.0, float centerY = 0.0,
                                int flags = 0)
   {
      al_draw_tinted_scaled_rotated_bitmap_region(
         _bitmap,
         srcX, srcY, width, height,
         al_map_rgba_f(tint[0], tint[1], tint[2], tint[3]),
         centerX, centerY,
         x, y,
         scaleX, scaleY,
         rotation,
         flags);
   }

   // Ditto
   public final void drawRegion(float x, float y,
                                float srcX, float srcY,
                                float width, float height,
                                float rotation,
                                float scaleX = 1.0, float scaleY = 1.0,
                                float[4] tint = [ 1.0, 1.0, 1.0, 1.0 ],
                                float centerX = 0.0, float centerY = 0.0,
                                int flags = 0)
   {
      al_draw_tinted_scaled_rotated_bitmap_region(
         _bitmap,
         srcX, srcY, width, height,
         al_map_rgba_f(tint[0], tint[1], tint[2], tint[3]),
         centerX, centerY,
         x, y,
         scaleX, scaleY,
         rotation,
         flags);
   }

   /**
    * The wrapped $(D ALLEGRO_BITMAP*). This is public just to make the $(D
    * alias this) work.
    */
   public ALLEGRO_BITMAP* _bitmap;

   // Let this be used with the Allegro functions.
   alias _bitmap this;
}
