/**
 * A low-level Bitmap resource.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.llr.bitmap;

import std.exception;
import std.string;
import allegro5.allegro;
import fewdee.allegro_manager;
import fewdee.engine;
import fewdee.llr.low_level_resource;


/**
 * A low-level bitmap resource. Encapsulates an $(D ALLEGRO_BITMAP*).
 *
 * Bitmaps are created using the flags set in the $(D Engine).
 */
public class Bitmap: LowLevelResource
{
   /**
    * Creates a Bitmap with the given dimensions. Throws if the bitmap cannot be
    * created.
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

   /**
    * The wrapped $(D ALLEGRO_BITMAP*). This is public just to make the $(D
    * alias this) work.
    */
   public ALLEGRO_BITMAP* _bitmap;

   // Let this be used with the Allegro functions.
   alias _bitmap this;
}
