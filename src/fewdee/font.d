/**
 * A low-level Font resource.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.font;

import std.exception;
import std.string;
import allegro5.allegro;
import allegro5.allegro_font;
import fewdee.allegro_manager;
import fewdee.color;
import fewdee.engine;
import fewdee.low_level_resource;


/**
 * A low-level font resource; a shallow wrapper on an $(D ALLEGRO_FONT*).
 *
 * Internally, Allegro creates a bitmap to store the font, so the bitmap
 * creation flags set in the $(D Engine) $(I do) matter here.
 *
 * TODO: Maybe I should (temporarily) disable things like mip-maps when creating
 *       fonts. Since fonts are always drawn at their "natural" size, mip-maps
 *       will only waste memory, I think.
 */
public class Font: LowLevelResource
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
    * Draws some text to the current render target using this font.
    *
    * Parameters:
    *   text = The text to draw.
    *   x = The horizontal coordinate of the point where the text will be drawn,
    *      in pixels, measured from the left.
    *   y = The vertical coordinate of the point where the text will be drawn,
    *      in pixels, measured from the top.
    *   color = The color to use when drawing the text.
    *   flags = Flags passed directly to Allegro's $(D al_draw_text()).
    *
    * TODO:
    *    Add some Allegro-free mean to request the text alignment.
    */
   public final void drawText(in string text, float x, float y,
                              Color color = WhiteColor,
                              int flags = ALLEGRO_ALIGN_LEFT)
   {
      import std.string;
      al_draw_text(_font, color, x, y, flags, text.toStringz);
   }

   /**
    * Draws some text with a border to the current render target using this
    * font.
    *
    * This is actually a bit of hack. The border is merely the result of drawing
    * the text multiple times with small offsets from the position where the
    * text itself will be drawn. Results may be better or worse depending on the
    * font used, its size, and offset used.
    *
    * Parameters:
    *   text = The text to draw.
    *   x = The horizontal coordinate of the point where the text will be drawn,
    *      in pixels, measured from the left.
    *   y = The vertical coordinate of the point where the text will be drawn,
    *      in pixels, measured from the top.
    *   textColor = The color to use when drawing the text.
    *   borderColor = The color of the border to use when drawing the text.
    *   borderOffset = The offset to use when drawing the border. This is
    *      roughly equals to the border width, in pixels. Experiment with this
    *      value until you find one that works nicely with the font you are
    *      using.
    *   flags = Flags passed directly to Allegro's $(D al_draw_text()).
    *
    * TODO:
    *    Add some Allegro-free mean to request the text alignment.
    */
   public final void drawBorderedText(in string text, float x, float y,
                                      Color textColor,
                                      Color borderColor,
                                      float borderOffset,
                                      int flags = ALLEGRO_ALIGN_LEFT)
   {
      import std.string;
      auto s = text.toStringz;
      alias borderOffset o;

      al_draw_text(_font, borderColor, x+o, y+o, flags, s);
      al_draw_text(_font, borderColor, x+o, y-o, flags, s);
      al_draw_text(_font, borderColor, x-o, y+o, flags, s);
      al_draw_text(_font, borderColor, x-o, y-o, flags, s);

      al_draw_text(_font, textColor, x, y, flags, s);
   }

   /**
    * The wrapped $(D ALLEGRO_FONT*). This is public just to make the $(D alias
    * this) work.
    */
   public ALLEGRO_FONT* _font;

   // Let this be used with the Allegro functions.
   alias _font this;
}
