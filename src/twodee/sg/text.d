/**
 * A scene graph Drawable that displays text.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.text;

import allegro5.allegro;
import allegro5.allegro_font;
import twodee.aabb;
import twodee.positionable;
import twodee.sg.drawable;


/// A scene graph Drawable that displays text.
class Text: Drawable, Positionable
{
   mixin PositionableDefaultImplementation!"recomputeAABB();";

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
    * Constructs the Text object.
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
      font_ = font;
      text_ = text;
      recomputeAABB();
   }

   /// Draws the text to the current target bitmap.
   public void draw()
   {
      al_draw_text(font_, ALLEGRO_COLOR(255, 255, 255, 255),
                   x, y, alignment_, text_.ptr);
   }

   /// Returns the text bounding box.
   public @property AABB aabb() const { return aabb_; }

   /// Gets the text alignment.
   public @property Alignment alignment() const { return alignment_; }

   /// Sets the text alignment.
   public @property void alignment(Alignment alignment)
   {
      alignment_ = alignment;
      recomputeAABB();
   }

   /// Recomputes the bounding box; stores it in aabb_.
   private void recomputeAABB()
   {
      int bbx, bby, bbw, bbh, ascent, descent;
      al_get_text_dimensions(font_, text_.ptr, &bbx, &bby, &bbw, &bbh,
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

      aabb_ = AABB(bbt, bbb, bbl, bbr);
   }

   /// The font used to draw the text.
   private ALLEGRO_FONT* font_;

   /// The text itself.
   private string text_;

   /// The text alignment.
   private Alignment alignment_ = Alignment.LEFT;

   /// The Text's bounding box
   private AABB aabb_;
}
