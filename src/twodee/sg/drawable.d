/**
 * A scene graph node that can be drawn.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.drawable;

import twodee.sg.node;
import twodee.sg.node_visitor;


/// A scene graph node that can draw itself.
class Drawable: Node
{
   /// Draws the Drawable to Allegro's "current bitmap".
   abstract public void draw();

   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public void accept(NodeVisitor visitor)
   {
      visitor.visit(this);
   }

   /// Gets the Drawable's "z-order".
   public @property float z() const { return z_; }

   /// Sets the Drawable's "z-order".
   public @property void z(float newZ) { z_ = newZ; }

   /*
    * The Drawable's "z-order". When using the standard means, Drawables with
    * lower z-order are drawn first. In other words, Drawables with higher "z"
    * are drawn over Drawables with lower "z". Drawables with the same "z-order"
    * can be drawn in any order.
    */
   private float z_ = 0.0;
}
