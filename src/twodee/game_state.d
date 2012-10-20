/**
 * Base class for the states the game can be in.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.game_state;

import twodee.state_manager;


/// Base class for the states the game can be in.
class GameState
{
   /// Pushes a state on top of this one. onBury() will be called.
   protected void pushState(GameState state)
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.pushState(state);
   }

   /// Pops this state from the stack of Game States.
   public void popState()
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.popState();
   }

   /**
    * Replaces this state in the top of the stack of Game States with a new
    * one. onDigOut() and onBury() are not called.
    */
   public void replaceState(GameState state)
   in
   {
      assert(stateManager_ !is null);
   }
   body
   {
      stateManager_.popState();
   }

   // /// Sets the root node for this state. This is what will be drawn.
   // public void setRootNode(Node node)
   // {
   //    rootNode_ = node;
   // }

   /// Called when a mouse down event is received.
   public void onMouseDown() { };

   /**
    * Called when this state is buried under another one (that is, when a new
    * state is pushed into the stack, just on top of this one).
    */
   public void onBury() { };

   /**
    * Called when this state becomes the one on the top of stack again, after
    * the state previously on top was popped.
    */
   public void onDigOut() { };

   // /**
   //  * The root node. This is what will be drawn while this state is the current
   //  * one.
   //  */
   // package Node rootNode_;

   /**
    * The StateManager managing this state. This is set by the StateManager
    * itself, as soon as this is added to it.
    */
   package StateManager stateManager_;
}
