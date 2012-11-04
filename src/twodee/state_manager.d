/**
 * Manager of Game States.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.state_manager;

import allegro5.allegro;
import twodee.event;
import twodee.game_state;


//
// TODO: - Use Allegro events to manage the stack of states?
//
//       - What if a state gets two events in the same "turn" and calls
//         pushState() in both of them? (Practical example: the player presses
//         "ESC" to get to the "in-game menu" state , and in the same "turn" he
//         is killed by a bullet, which triggers a transition to the "game over"
//         state.)
//



/**
 * Manager of Game States. Manages a stack of states and the provides the
 * necessary methods to handle it.
 */
struct StateManager
{
   /// Returns the state at the top of the stack.
   public @property GameState top()
   in
   {
      assert(states_.length > 0);
   }
   body
   {
      return states_[$-1];
   }

   /// Checks whether the stack of states is empty.
   public @property bool empty() const { return states_.length == 0; }

   /// Pushes a state into the stack of Game States.
   void pushState(GameState state)
   {
      if (states_.length > 0)
         states_[$-1].onBury();

      states_ ~= state;
      state.stateManager_ = &this;
   }

   /// Pops the state on the top of the stack of Game States.
   void popState()
   {
      states_ = states_[0 .. $-1];
      if (states_.length > 0)
         states_[$-1].onDigOut();
   }

   /**
    * Replaces the state in the top of the stack of Game States with a new
    * one. onDigOut() and onBury() are not called.
    */
   void replaceState(GameState state)
   in
   {
      assert(states_.length > 0);
   }
   body
   {
      states_[$-1] = state;
      state.stateManager_ = &this;
   }

   /// Called periodically. This is the place to do all the drawing.
   public void onDraw()
   {
      foreach(state; states_)
      {
         if (state.wantsToDraw)
            state.onDraw();
      }
   }

   /**
    * Called when an event (any event) is received. This method just forwards
    * the event to all states that want to receive it.
    *
    * Parameters:
    *    event = The event received.
    */
   public void onEvent(in ref ALLEGRO_EVENT event)
   {
      foreach(state; states_)
      {
         immutable wants = event.type == TWODEE_EVENT_TICK
            ? state.wantsTicks
            : state.wantsEvents;

         if (wants)
            state.onEvent(event);
      }
   }

   /// An array of Game States, used as a stack.
   private GameState[] states_;
}
