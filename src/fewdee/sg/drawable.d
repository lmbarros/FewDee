/**
 * A scene graph node that can be drawn.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.drawable;

import fewdee.sg.node;
import fewdee.sg.node_visitor;


/// A scene graph node that can draw itself.
public class Drawable: Node
{
   /// Draws the $(D Drawable) to Allegro's "current bitmap".
   abstract public void draw();

   /// Accepts a $(D NodeVisitor). The Visitor pattern, you know.
   public override void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);
      visitor.visit(this);
      visitor.popNodeFromNodePath(this);
   }

   /**
    * The $(D Drawable)'s "z-order".
    *
    * When using the standard means, $(D Drawable)s with lower z-order are drawn
    * first. In other words, $(D Drawable)s with higher "z" are drawn over $(D
    * Drawable)s with lower "z". $(D Drawable)s with the same "z-order" can be
    * drawn in any order.
    */
   public final @property float z() const { return z_; }

   /// Ditto
   public final @property void z(float newZ) { z_ = newZ; }

   /// The $(D Drawable)'s "z-order".
   private float z_ = 0.0;
}
