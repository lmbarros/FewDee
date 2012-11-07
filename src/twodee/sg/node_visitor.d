/**
 * Base class for node visitors.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.node_visitor;

import twodee.sg.drawable;
import twodee.sg.group;
import twodee.sg.node;
import twodee.sg.srt;


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

   /// Called when visiting a SRT. Override as necessary in subclasses.
   public void visit(SRT node) { }
}
