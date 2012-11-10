/**
 * A scene graph node that can have children.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.group;

import twodee.aabb;
import twodee.sg.node;
import twodee.sg.node_visitor;


/// A scene graph node that can have children.
class Group: Node
{
   /// Adds a given node as child of this Group.
   public void addChild(Node node)
   {
      children_ ~= node;
      node.parents_ ~= this;
   }

   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public override void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);

      visitor.visit(this);

      foreach(node; children_)
         node.accept(visitor);

      visitor.popNodeFromNodePath(this);
   }

   /**
    * Returns the node's bounding rectangle. The returned rectangle shall be in
    * the local coordinate system of this Node.
    */
   public @property AABB aabb() const
   {
      if (children_.length == 0)
         return EmptyAABB;

      auto aabb = children_[0].aabb;
      foreach(child; children_[1..$])
         aabb.unionWith(child.aabb);

      return aabb;
   }

   /// The child nodes of this Group.
   protected Node[] children_;
}
