/**
 * A scene graph node.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.node;

import fewdee.aabb;
import fewdee.sg.group;
import fewdee.sg.node_visitor;


/// A scene graph node.
class Node
{
   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);
      visitor.visit(this);
      visitor.popNodeFromNodePath(this);
   }


   /**
    * Returns the node's bounding rectangle. The returned rectangle shall be in
    * the local coordinate system of this Node.
    */
   abstract public @property AABB aabb();


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


   /// Removes this node from all its parents.
   public void makeOrphan()
   {
      foreach (parent; parents_)
         parent.removeChild(this);
   }

   /// Returns the number of parents this node has.
   public @property int numParents() const { return parents_.length; }

   unittest
   {
      auto g1 = new Group();
      auto g2 = new Group();
      auto c = new Group();

      // Add the same node to two parent nodes
      assert(c.numParents == 0);
      g1.addChild(c);
      g2.addChild(c);
      assert(c.numParents == 2);
      assert(g1.numChildren == 1);
      assert(g2.numChildren == 1);

      // Remove the node from all parents
      c.makeOrphan();
      assert(c.numParents == 0);
      assert(g1.numChildren == 0);
      assert(g2.numChildren == 0);
   }


   /**
    * This Node's parents. A node can be present in multiple points of the scene
    * graph, that's why multiple parents are possible.
    */
   package Group[] parents_;
}
