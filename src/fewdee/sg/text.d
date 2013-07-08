/**
 * A scene graph $(D Drawable) that displays text.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.text;

import std.string;
import allegro5.allegro;
import allegro5.allegro_font;
import fewdee.aabb;
import fewdee.color;
import fewdee.sg.drawable;
import fewdee.internal.default_implementations;


/// A scene graph $(D Drawable) that displays text.
public class Text: Drawable
{
   mixin PositionableDefaultImplementation!"dirtyAABB();";
   mixin ColorableDefaultImplementation;

   /// An enumeration of the possible text alignments.
   public enum Alignment
   {
      /// Left-align the text.
      LEFT = ALLEGRO_ALIGN_LEFT,

      /// Center the text.
      CENTER = ALLEGRO_ALIGN_CENTRE,

      /// Right-align the text.
      RIGHT = ALLEGRO_ALIGN_RIGHT,
   }

   /**
    * Constructs the $(D Text) object.
    *
    * Parameters:
    *    font = The font to use to when drawing the text.
    *    text = Text to use when drawing the text.
    */
   this(ALLEGRO_FONT* font, string text)
   in
   {
      assert(font !is null);
   }
   body
   {
      _font = font;
      _text = text;
   }

   /// Draws the text to the current target bitmap.
   public override void draw()
   {
      al_draw_text(_font, color, x, y, _alignment, _text.ptr);
   }

   /// The text alignment.
   public final @property Alignment alignment() const { return _alignment; }

   /// Ditto.
   public final @property void alignment(Alignment alignment)
   {
      _alignment = alignment;
      dirtyAABB();
   }

   // Inherit docs.
   protected override void recomputeAABB(ref AABB aabb)
   {
      int bbx, bby, bbw, bbh, ascent, descent;
      al_get_text_dimensions(_font, _text.toStringz, &bbx, &bby, &bbw, &bbh,
                             &ascent, &descent);

      float dx;
      final switch(alignment)
      {
         case Alignment.LEFT: dx = 0.0; break;
         case Alignment.RIGHT: dx = bbw; break;
         case Alignment.CENTER: dx = bbw / 2.0; break;
      }

      auto bbl = x + bbx - dx;
      auto bbr = bbl + bbw;
      auto bbt = y + bby;
      auto bbb = bbt + bbh;

      aabb = AABB(bbt, bbb, bbl, bbr);
   }

   /// The font used to draw the text.
   private ALLEGRO_FONT* _font;

   /// The text itself.
   private string _text;

   /// The text alignment.
   private Alignment _alignment = Alignment.LEFT;
}
