/**
 * A simple example showing the use of game states. We create a few states and
 * allow the user to change between them by pressing some keys.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import fewdee.all;


// All states in this example are very similar to each other. To avoid
// duplicated code, this class contains everything shared among our game states.
class BaseState: GameState
{
   this()
   {
      font_ = al_load_ttf_font("data/bluehigl.ttf", 30, 0);
      enforce(font_ !is null);
   }

   ~this()
   {
      al_destroy_font(font_);
   }

   protected void drawText(string text, float x, float y)
   {
      al_draw_text(font_, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                   text.ptr);
   }

   protected ALLEGRO_FONT* font_;
}


class InitialState: BaseState
{
   this()
   {
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_SPACE)
                             pushState(new StateA());
                          else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(10, 10, 50));
      drawText("Initial State", 30, 30);
      drawText("Press space to push a State A", 50, 60);
      drawText("Press ESC to quit", 50, 90);
   }
};


class StateA: BaseState
{
   this()
   {
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_B)
                             replaceState(new StateB());
                          else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(50, 10, 10));
      drawText("State A", 30, 30);
      drawText("Press ESC to go back to the initial state", 50, 60);
      drawText("Press \"B\" to replace this state with State B", 50, 90);
   }
}

class StateB: BaseState
{
   this()
   {
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_A)
                             replaceState(new StateA());
                          else if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(10, 50, 10));
      drawText("State B", 30, 30);
      drawText("Press ESC to go back to the initial state", 50, 60);
      drawText("Press \"A\" to replace this state with State A", 50, 90);
   }
}

void main()
{
   auto engine = Engine(640, 480);
   engine.run(new InitialState());
}
