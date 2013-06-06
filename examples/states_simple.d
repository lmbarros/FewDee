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


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
private class InitialState: GameState
{
   public this()
   {
      addHandler(ALLEGRO_EVENT_KEY_DOWN,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    import std.stdio; writefln("Handling keydown (%s)", this);

                    if (event.keyboard.keycode == ALLEGRO_KEY_SPACE)
                       pushState(new StateA());
                    else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                       popState();

                    import std.stdio; writefln("Handled keydown");
                 });

      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    import std.stdio; writefln("Handling draw (%s)", this);
                    al_clear_to_color(al_map_rgb(10, 10, 50));
                    drawText("Initial State", 30, 30);
                    drawText("Press space to push a State A", 50, 60);
                    drawText("Press ESC to quit", 50, 90);
                    import std.stdio; writefln("Handled draw (%s)", this);
                 });
   }
};


private class StateA: GameState
{
   public this()
   {
      addHandler(ALLEGRO_EVENT_KEY_DOWN,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    if (event.keyboard.keycode == ALLEGRO_KEY_B)
                       replaceState(new StateB());
                    else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                       popState();
                 });

      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    al_clear_to_color(al_map_rgb(50, 10, 10));
                    drawText("State A", 30, 30);
                    drawText("Press ESC to go back to the initial state", 50, 60);
                    drawText("Press \"B\" to replace this state with State B", 50, 90);
                 });
   }
}

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

      addHandler(FEWDEE_EVENT_DRAW,
                 delegate(in ref ALLEGRO_EVENT event)
                 {
                    al_clear_to_color(al_map_rgb(10, 50, 10));
                    drawText("State B", 30, 30);
                    drawText("Press ESC to go back to the initial state", 50, 60);
                    drawText("Press \"A\" to replace this state with State A", 50, 90);
                 });
   }
}

void main()
{
   scope crank = new fewdee.engine.Crank();
   DisplayManager.createDisplay("default");

   theFont = new Font("data/bluehigl.ttf", 30);

   Engine.run(new InitialState());

   // As said above, we are managing resources manually. Resources must be
   // explicitly freed if they are not being managed by the 'ResourceManager'.
   theFont.free();
}
