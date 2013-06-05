/**
 * A low-level Font resource.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.llr.font;

import std.exception;
import std.string;
import allegro5.allegro_font;
import fewdee.allegro_manager;
import fewdee.engine;
import fewdee.llr.low_level_resource;


/**
 * A low-level font resource. Encapsulates an $(D ALLEGRO_FONT*).
 *
 * Internally, Allegro creates a bitmap to store the font, so the bitmap
 * creation flags set in the $(D Engine) do matter here.
 *
 * TODO: Maybe I should (temporarily) disable things like mip-maps when creating
 *       fonts. Since fonts are always drawn at their "natural" size, mip-maps
 *       will only waste memory, I think.
 */
class Font: LowLevelResource
{
   /**
    * Creates a Font, loading the data from a given file.
    *
    * Parameters:
    *    path = The path to the font file.
    *    size = The font size, in pixels. This is passed directly to $(D
    *       al_load_ttf_font()), so you may wish to know that "[t]he standard
    *       font size is measured in units per EM, if you instead want to
    *       specify the size as the total height of glyphs in pixels, pass it as
    *       a negative value." (from Allegro documentation).
    *    flags = These flags are passed directly to $(D al_load_ttf_font()).
    */
   this(in string path, int size, int flags = 0)
   {
      AllegroManager.initImageIO();
      AllegroManager.initTTF();
      Engine.applyBitmapCreationFlags();
      _font = al_load_font(path.toStringz, size, flags);
      enforce(_font !is null, "Couldn't load font from '" ~ path ~  "'");
   }

   /// Frees all resources used by the Font.
   public void free()
   {
      al_destroy_font(_font);
      _font = null;
   }

   /**
    * The wrapped $(D ALLEGRO_FONT*). This is public just to make the $(D alias
    * this) work.
    */
   public ALLEGRO_FONT* _font;

   // Let this be used with the Allegro functions.
   alias _font this;
}
