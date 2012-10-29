/**
 * A scene graph node.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.node;

import twodee.aabb;
import twodee.node_visitor;


/// A scene graph node.
class Node
{
   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public void accept(NodeVisitor visitor)
   {
      visitor.visit(this);
   }

   /// Returns the node's bounding rectangle.
   abstract public @property AABB aabb() const;

   /**
    * Checks whether a given point is contained by this Node. The default
    * implementation uses a simple bounding box-based test.
    */
   public bool contains(float x, float y)
   {
      return aabb.contains(x, y);
   }

   /**
    * This Node's parents. A node can be present in multiple points of the scene
    * graph, that's why multiple parents are possible.
    */
   package Node[] parents_;
}
