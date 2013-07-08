/**
 * A visitor used to draw a scene graph.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.drawing_visitor;

import allegro5.allegro;
import std.algorithm;
import fewdee.sg.node;
import fewdee.sg.drawable;
import fewdee.sg.node_visitor;
import fewdee.sg.srt;


/**
 * A visitor used to draw a scene graph. After doing the traversal, you must
 * call the $(D draw()) method to issue the actual drawing commands.
 *
 * See_also: draw()
 */
public class DrawingVisitor: NodeVisitor
{
   alias NodeVisitor.visit visit;

   /**
    * Add the $(D Drawable) to $(D collectedDrawables_), with its respective
    * transform.
    */
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

   /**
    * Draws all $(D Drawable)s in $(D collectedDrawables_), using the proper
    * transforms.
    */
   public void draw()
   {
      sort!("a.d.z < b.d.z")(collectedDrawables_);

      foreach(collectedDrawable; collectedDrawables_)
      {
         al_use_transform(&collectedDrawable.t);
         collectedDrawable.d.draw();
      }
   }

   /// Important information concerning a $(D Drawable) that will be drawn.
   private struct CollectedDrawable
   {
      /// The $(D Drawable) itself.
      Drawable d;

      /// The transform to use when drawing the $(D Drawable).
      ALLEGRO_TRANSFORM t;
   }

   /**
    * A collection of $(D Drawable)s (and other data concerning these $(D
    * Drawable)s) that will be drawn.
    */
   private CollectedDrawable[] collectedDrawables_;
}



/**
 * Handy way to draw a scene graph.
 *
 * It instantiates a $(D DrawingVisitor), makes it traverse the scene graph from
 * a given root nod, and calls $(D DrawingVisitor.draw()).
 */
public void draw(Node root)
{
   auto dv = new DrawingVisitor();
   root.accept(dv);
   dv.draw();
}
