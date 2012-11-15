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


   /// Returns the number of children.
   public @property size_t numChildren() const { return children_.length; }

   unittest
   {
      auto g = new Group();

      // No children just after construction
      assert(g.numChildren == 0);

      // Add children, check if the number of children matches
      g.addChild(new Group());
      assert(g.numChildren == 1);

      g.addChild(new Group());
      assert(g.numChildren == 2);

      g.addChild(new Group());
      assert(g.numChildren == 3);
   }


   /**
    * Gets the index of a given child.
    *
    * Parameters:
    *    node = The child whose index is desired.
    *
    * Return: The index of node. If node was added multiple times as child,
    *    returns the index of the first occurrence. If node is not a child of
    *    this Group, returns a negative number.
    */
   public int childIndex(in Node node)
   {
      foreach (index, child; children_)
      {
         if (child == node)
            return index;
      }

      return -1;
   }

   unittest
   {
      auto g = new Group();

      auto c1 = new Group();
      auto c2 = new Group();
      auto c3 = new Group();
      auto c4 = new Group();

      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c3);
      g.addChild(c4);
      auto notThere = new Group();

      assert(g.childIndex(c1) == 0);
      assert(g.childIndex(c2) == 1);
      assert(g.childIndex(c3) == 2);
      assert(g.childIndex(c4) == 3);
      assert(g.childIndex(notThere) < 0);

      // Now with some repetitions
      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c1);

      assert(g.childIndex(c1) == 0);
      assert(g.childIndex(c2) == 1);
      assert(g.childIndex(c3) == 2);
      assert(g.childIndex(c4) == 3);
   }


   /**
    * Removes a given child from the list of children. If the requested node is
    * present multiple times as a child of this Group, only its first occurrence
    * will be removed.
    *
    * Parameters:
    *    node = The node to remove.
    *
    * Return: true if the node was removed; false if it was not removed
    *    (necessarily because it is not a child of this Group).
    */
   public bool removeChild(in Node node)
   {
      immutable i = childIndex(node);
      if (i < 0)
         return false;

      foreach (index, childParent; children_[i].parents_)
      {
         if (childParent == this)
         {
            children_[i].parents_ = children_[i].parents_[0..index]
               ~ children_[i].parents_[index+1..$];
            break;
         }
      }

      children_ = children_[0..i] ~ children_[i+1..$];

      return true;
   }

   unittest
   {
      auto g = new Group();

      auto c1 = new Group();
      auto c2 = new Group();
      auto c3 = new Group();
      auto c4 = new Group();
      auto notThere = new Group();

      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c3);
      g.addChild(c4);

      // If the node is not a child, return shall be false
      assert(g.removeChild(notThere) == false);

      // Remove a node, check if the number of children was reduced by one
      assert(g.numChildren == 4);
      assert(g.removeChild(c2) == true);
      assert(g.numChildren == 3);

      // The order of the remaining nodes shall remain the same
      assert(g.childIndex(c1) == 0);
      assert(g.childIndex(c3) == 1);
      assert(g.childIndex(c4) == 2);
   }

   unittest
   {
      // Removing a child present multiple times as child
      auto g = new Group();

      auto c1 = new Group();
      auto c2 = new Group();

      g.addChild(c2);
      g.addChild(c1);
      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c1);

      // We shall consider that we have five children, even if some are repeated
      assert(g.numChildren == 5);

      // Remove a node with repetitions
      g.removeChild(c1);
      assert(g.numChildren == 4);
      assert(g.childIndex(c1) == 1);
      assert(g.childIndex(c2) == 0);
   }

   unittest
   {
      // Corner case: removing the first child
      auto g = new Group();

      auto c1 = new Group();
      auto c2 = new Group();
      auto c3 = new Group();
      auto c4 = new Group();

      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c3);
      g.addChild(c4);

      assert(g.removeChild(c1) == true);
      assert(g.numChildren == 3);

      assert(g.childIndex(c2) == 0);
      assert(g.childIndex(c3) == 1);
      assert(g.childIndex(c4) == 2);
   }

   unittest
   {
      // Corner case: removing the last child
      auto g = new Group();

      auto c1 = new Group();
      auto c2 = new Group();
      auto c3 = new Group();
      auto c4 = new Group();

      g.addChild(c1);
      g.addChild(c2);
      g.addChild(c3);
      g.addChild(c4);

      assert(g.removeChild(c4) == true);
      assert(g.numChildren == 3);

      assert(g.childIndex(c1) == 0);
      assert(g.childIndex(c2) == 1);
      assert(g.childIndex(c3) == 2);
   }

   unittest
   {
      // Corner case: removing the only child
      auto g = new Group();
      auto c1 = new Group();
      g.addChild(c1);

      assert(g.removeChild(c1) == true);
      assert(g.numChildren == 0);
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
   public override @property AABB aabb()
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
