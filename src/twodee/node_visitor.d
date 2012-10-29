/**
 * Base class for node visitors.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.node_visitor;

import twodee.drawable;
import twodee.group;
import twodee.node;


/**
 * Base class for node visitors. Used to traverse the scene graph using the
 * Visitor pattern.
 */
class NodeVisitor
{
   /// Called when visiting a Drawable. Override as necessary in subclasses.
   public void visit(Drawable node) { }

   /// Called when visiting a Node. Override as necessary in subclasses.
   public void visit(Node node) { }

   /// Called when visiting a Group. Override as necessary in subclasses.
   public void visit(Group node) { }
}
