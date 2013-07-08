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
public class Node
{
   //
   // Parent-child relationship
   //

   /// Removes this node from all its parents.
   public final void makeOrphan()
   {
      foreach (parent; parents_)
         parent.removeChild(this);
   }

   /// Returns the number of parents this node has.
   public final @property int numParents() const { return parents_.length; }

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
    * This $(D Node)'s parents. A node can be present in multiple points of the
    * scene graph, that's why multiple parents are possible.
    */
   package Group[] parents_;


   //
   // AABB-related stuff
   //

   /**
    * Returns the node's bounding rectangle. The returned rectangle shall be in
    * the local coordinate system of this $(D Node).
    */
   public final @property AABB aabb()
   {
      if (isDirtyAABB)
      {
         recomputeAABB(_aabb);
         _isDirtyAABB = false;
      }

      return _aabb;
   }

   /**
    * Flags the bounding rectangle as dirty. As a result, it will be recomputed
    * the next time it is requested.
    *
    * Subclasses are expected to call this whenever appropriate.
    */
   protected final void dirtyAABB()
   {
      _isDirtyAABB = true;
   }

   /// Is the bounding box flagged as dirty?
   protected final @property bool isDirtyAABB() const
   {
      return _isDirtyAABB;
   }

   /**
    * Recomputes the bounding box. This gets called whenever the bounding box is
    * requested and it is flagged as dirty.
    *
    * Parameters:
    *    aabb = The updated bounding box value shall be written here.
    */
   protected abstract void recomputeAABB(ref AABB aabb);

   /// The (possibly dirty) bounding box.
   private AABB _aabb;

   /// Is the bounding box ($(D _aabb)) dirty?
   private bool _isDirtyAABB = true;


   //
   // Assorted methods
   //

   /**
    * Checks whether a given point is contained by this $(D Node). The point
    * passed is assumed to be in the node's local coordinate system.
    *
    * The default implementation uses a simple bounding box-based test.
    */
   public bool contains(float x, float y)
   {
      return aabb.contains(x, y);
   }

   /// Accepts a $(D NodeVisitor). The Visitor pattern, you know.
   public void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);
      visitor.visit(this);
      visitor.popNodeFromNodePath(this);
   }
}
