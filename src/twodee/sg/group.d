/**
 * A scene graph node that can have children.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.group;

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
      visitor.visit(this);

      foreach(node; children_)
         node.accept(visitor);
   }

   /// The child nodes of this Group.
   protected Node[] children_;
}
