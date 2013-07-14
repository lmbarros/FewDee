/**
 * FewDee's "Simple States" example.
 *
 * A simple example showing the use of game states. We create a few states and
 * allow the user to change between them by pressing some keys.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import fewdee.all;

// This font is the only resource used in this example. In real programs, you'll
// probably want to use the 'ResourceManager', but since we are focusing on the
// 'StateManager' and 'GameState', we'll do all resource management manually.
private Font theFont;


// We'll want to draw some text, so here is something that will help us. Again,
// we are avoiding to use higher level abstractions provided by FewDee, in order
// to focus on what this example is supposed to be about. Anyway, notice how the
// FewDee wrappers (like Font) work seamlessly with the Allegro API.
private void drawText(string text, float x, float y)
in
{
   assert(theFont !is null);
}
body
{
   al_draw_text(
      theFont, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT, text.ptr);
}


// This is the state in which the example starts.
private class InitialState: GameState
{
   // In the constructor, we register the two event handlers we need: one to
   // handle key presses, and to handle drawing.
   public this()
   {
      // When pressing space, push a new 'StateA' state on top of this one
      // (which will become the new current state). When pressing "Escape", pop
      // this state from the stack of states (and, since this is the last state
      // in the stack, the stack will become empty and the program will exit
      // main loop).
      addHandler(ALLEGRO_EVENT_KEY_DOWN,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    if (event.keyboard.keycode == ALLEGRO_KEY_SPACE)
                       pushState(new StateA());
                    else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                       popState();
                 });

      // Handle drawing. Just use a blueish background color and print some
      // informative text.
      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    al_clear_to_color(al_map_rgb(10, 10, 50));
                    drawText("Initial State", 30, 30);
                    drawText("Press space to push a State A", 50, 60);
                    drawText("Press ESC to quit", 50, 90);
                 });
   }
};



// The 'StateA' game state.
private class StateA: GameState
{
   public this()
   {
      // Handles key presses. Similar to the handler of 'InitialState'; the
      // novelty here is the use of 'replaceState()', which will take the
      // current state out of the stack, and replace it another one (a
      // 'StateB').
      addHandler(ALLEGRO_EVENT_KEY_DOWN,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    if (event.keyboard.keycode == ALLEGRO_KEY_B)
                       replaceState(new StateB());
                    else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                       popState();
                 });

      /// Nothing new here. Reddish background and informational texts.
      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    al_clear_to_color(al_map_rgb(50, 10, 10));
                    drawText("State A", 30, 30);
                    drawText("Press ESC to go back to the initial state",
                             50, 60);
                    drawText("Press \"B\" to replace this state with State B",
                             50, 90);
                 });
   }
}


// And yet another state. Very similar to the one we just defined.
private class StateB: GameState
{
   public this()
   {
      addHandler(ALLEGRO_EVENT_KEY_DOWN,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    if (event.keyboard.keycode == ALLEGRO_KEY_A)
                       replaceState(new StateA());
                    else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                       popState();
                 });

      // Greenish background, and (this is getting repetitive...) informational
      // texts.
      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    al_clear_to_color(al_map_rgb(10, 50, 10));
                    drawText("State B", 30, 30);
                    drawText("Press ESC to go back to the initial state",
                             50, 60);
                    drawText("Press \"A\" to replace this state with State A",
                             50, 90);
                 });
   }
}



// Program execution starts here.
void main()
{
   // Start the engine.
   scope crank = new fewdee.engine.Crank();

   // Create a display named "main", using default settings.
   DisplayManager.createDisplay("main");

   // Load the font. This will throw if some error happens.
   theFont = new Font("data/bluehigl.ttf", 30);

   // Starts the game main loop, with an 'InitialState' as the starting
   // state. The loop will run as long as there is at least one state in the
   // stack of states maintained by the 'StateManager'.
   run(new InitialState());

   // As said above, we are managing resources manually. Resources must be
   // explicitly freed if they are not being managed by the 'ResourceManager'.
   theFont.free();
}
