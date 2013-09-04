/**
 * Base class for node visitors.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.node_visitor;

import fewdee.sg.drawable;
import fewdee.sg.group;
import fewdee.sg.node;
import fewdee.sg.srt;


/**
 * Base class for node visitors. Used to traverse the scene graph using the
 * Visitor pattern.
 */
public class NodeVisitor
{
   /**
    * Called when visiting a $(D Drawable). Override as necessary in subclasses.
    */
   public void visit(Drawable node) { }

   /// Called when visiting a $(D Node). Override as necessary in subclasses.
   public void visit(Node node) { }

   /// Called when visiting a $(D Group). Override as necessary in subclasses.
   public void visit(Group node) { }

   /// Called when visiting a $(D SRT). Override as necessary in subclasses.
   public void visit(SRT node) { }

   /**
    * Returns the path of nodes from the scene graph root to the node currently
    * being visited.
    */
   protected final @property Node[] nodePath() { return nodePath_; }

   /// Pushes a node to the node path.
   package final void pushNodeToNodePath(Node node)
   {
      nodePath_ ~= node;
   }

   /// Pops a node from the node path.
   package final void popNodeFromNodePath(Node node)
   {
      nodePath_ = nodePath_[0..$-1];
   }

   /**
    * The path of nodes from the scene graph root to the node currently being
    * visited.
    */
   private Node[] nodePath_;
}
