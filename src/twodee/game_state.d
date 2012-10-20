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

   /**
    * Called when this state is buried under another one (that is, when a new
    * state is pushed into the stack, just on top of this one).
    */
   public void onBury()
   {
      wantsTicks = false;
      wantsEvents = false;
   };

   /**
    * Called when this state becomes the one on the top of stack again, after
    * the state previously on top was popped.
    */
   public void onDigOut()
   {
      wantsTicks = true;
      wantsEvents = true;
   };

   /**
    * Called periodically. This is the place to update the world state.
    *
    * Parameters:
    *   deltaTime = The time, in seconds, elapsed since the previous call to
    *               onTick().
    */
   public void onTick(double deltaTime) { };

   /// Called periodically. This is the place to do all the drawing.
   public void onDraw() { };

   /// Called when a mouse down event is received.
   public void onMouseDown() { };

   /// Does this GameState want to receive "tick" events?
   public @property bool wantsTicks() const { return wantsTicks_; }

   /// Does this GameState want to receive "tick" events?
   public @property wantsTicks(bool wants) { wantsTicks_ = wants; }

   /// Does this GameState want to receive events other than "tick"?
   public @property bool wantsEvents() const { return wantsEvents_; }

   /// Does this GameState want to receive events other than "tick"?
   public @property wantsEvents(bool wants) { wantsEvents_ = wants; }

   /// Does this GameState want to draw?
   public @property bool wantsToDraw() const { return wantsToDraw_; }

   /// Does this GameState want to draw?
   public @property wantsToDraw(bool wants) { wantsToDraw_ = wants; }

   /**
    * The StateManager managing this state. This is set by the StateManager
    * itself, as soon as this is added to it.
    */
   package StateManager stateManager_;

   /// Does this GameState want to receive "tick" events?
   private bool wantsTicks_ = true;

   /// Does this GameState want to receive events other than "tick"?
   private bool wantsEvents_ = true;

   /// Does this GameState want to draw?
   private bool wantsToDraw_ = true;
}
