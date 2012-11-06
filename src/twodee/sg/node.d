/**
 * A scene graph node.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.node;

import twodee.aabb;
import twodee.sg.node_visitor;


/// A scene graph node.
class Node
{
   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public void accept(NodeVisitor visitor)
   {
      visitor.visit(this);
   }

   /**
    * Returns the node's bounding rectangle. The returned rectangle shall be in
    * the local coordinate system of this Node.
    */
   abstract public @property AABB aabb() const;

   /**
    * Checks whether a given point is contained by this Node. The point passed
    * is assumed to be in the Node's local coordinate system.
    *
    * The default implementation uses a simple bounding box-based test.
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
