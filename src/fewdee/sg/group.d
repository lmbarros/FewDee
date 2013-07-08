/**
 * A scene graph node that can have children.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.group;

import fewdee.aabb;
import fewdee.sg.node;
import fewdee.sg.node_visitor;


/// A scene graph node that can have children.
public class Group: Node
{
   //
   // Parent-child relationship
   //

   /// Adds a given node as child of this $(D Group).
   public void addChild(Node node)
   {
      _children ~= node;
      node.parents_ ~= this;
   }

   /// Returns the number of children.
   public final @property size_t numChildren() const
   {
      return _children.length;
   }

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
    * Returns:
    *    The index of $(D node). If $(D node) was added multiple times as child,
    *    returns the index of the first occurrence. If $(D node) is not a child
    *    of this $(D Group), returns a negative number.
    */
   public int childIndex(in Node node)
   {
      foreach (index, child; _children)
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
    * Removes a given node from the list of children. If the requested node is
    * present multiple times as a child of this $(D Group), only its first
    * occurrence will be removed.
    *
    * Parameters:
    *    node = The node to remove.
    *
    * Returns:
    *    $(D true) if the node was removed; $(D false) if it was not removed
    *    (which implies that it wasn't a child of this $(D Group)).
    */
   public bool removeChild(in Node node)
   {
      immutable i = childIndex(node);
      if (i < 0)
         return false;

      foreach (index, childParent; _children[i].parents_)
      {
         if (childParent == this)
         {
            _children[i].parents_ = _children[i].parents_[0..index]
               ~ _children[i].parents_[index+1..$];
            break;
         }
      }

      _children = _children[0..i] ~ _children[i+1..$];

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

   /// The child nodes of this Group.
   protected Node[] _children;


   //
   // Assorted methods
   //

   /// Accepts a $(D NodeVisitor). The Visitor pattern, you know.
   public override void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);

      visitor.visit(this);

      foreach(node; _children)
         node.accept(visitor);

      visitor.popNodeFromNodePath(this);
   }

   // Inherit docs
   protected override void recomputeAABB(ref AABB aabb)
   {
      if (_children.length == 0)
         aabb = EmptyAABB;

      auto newAABB = _children[0].aabb;
      foreach(child; _children[1..$])
         newAABB.unionWith(child.aabb);

      aabb = newAABB;
   }
}
