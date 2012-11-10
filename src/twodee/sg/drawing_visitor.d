/**
 * A visitor used to draw a scene graph.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.drawing_visitor;

import allegro5.allegro;
import twodee.sg.drawable;
import twodee.sg.node_visitor;
import twodee.sg.srt;


/**
 * A visitor used to draw a scene graph. After doing the traversal, you must
 * call the draw() method to issue the actual drawing commands.
 */
class DrawingVisitor: NodeVisitor
{
   alias NodeVisitor.visit visit;

   /// Add the drawable to collectedDrawables_, with its respective transform.
   public override void visit(Drawable d)
   {
      // Compute the transformation
      ALLEGRO_TRANSFORM t;
      al_identity_transform(&t);
      foreach_reverse(n; nodePath)
      {
         auto srt = cast(SRT)n;

         if (srt !is null)
            al_compose_transform(&t, srt.transform);
      }

      // Add the drawable to collectedDrawables_
      collectedDrawables_ ~= CollectedDrawable(d, t);
   }

   /// Draws all Drawables in collectedDrawables_, using the proper transforms.
   public void draw()
   {
      foreach(collectedDrawable; collectedDrawables_)
      {
         al_use_transform(&collectedDrawable.t);
         collectedDrawable.d.draw();
      }
   }

   /// Important information concerning a Drawable that will be drawn.
   private struct CollectedDrawable
   {
      /// The Drawable itself
      Drawable d;

      /// The transform to use when drawing the Drawable
      ALLEGRO_TRANSFORM t;
   }

   /**
    * A collection of Drawables (and other data concerning these Drawables) that
    * will be drawn.
    */
   private CollectedDrawable[] collectedDrawables_;
}
