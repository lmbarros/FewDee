/**
 * A scene graph Drawable that displays text.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.text;

import allegro5.allegro;
import allegro5.allegro_font;
import fewdee.aabb;
import fewdee.colorable;
import fewdee.positionable;
import fewdee.sg.drawable;


/// A scene graph Drawable that displays text.
class Text: Drawable, Positionable, Colorable
{
   mixin PositionableDefaultImplementation!"isAABBDirty_ = true;";
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
   }

   /// Draws the text to the current target bitmap.
   public override void draw()
   {
      al_draw_text(font_, color, x, y, alignment_, text_.ptr);
   }


   /// Returns the text bounding box.
   public override @property AABB aabb()
   {
      if (isAABBDirty_)
         recomputeAABB();
      return aabb_;
   }


   /// Gets the text alignment.
   public @property Alignment alignment() const { return alignment_; }

   /// Sets the text alignment.
   public @property void alignment(Alignment alignment)
   {
      alignment_ = alignment;
      isAABBDirty_ = true;
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

      isAABBDirty_ = false;
   }

   /// The font used to draw the text.
   private ALLEGRO_FONT* font_;

   /// The text itself.
   private string text_;

   /// The text alignment.
   private Alignment alignment_ = Alignment.LEFT;

   /// The Text's bounding box
   private AABB aabb_;

   /// Is the bounding box dirty?
   private bool isAABBDirty_ = true;
}
