

import allegro5.allegro;

import twodee.engine;
import twodee.game_state;
import twodee.state_manager;


class MyState: GameState
{
   this()
   {
      logo_ = al_load_bitmap("data/logo.png");
      addEventHandler(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
   }

   void onDraw()
   {
      al_clear_to_color(al_map_rgb(200, 200, 0));

      al_draw_bitmap(logo_, 0.0, 0.0, 0);
      al_draw_bitmap(logo_, 20.0, 0.0, 0);
      al_draw_bitmap(logo_, 120.0, 0.0, 0);

      al_draw_rotated_bitmap(logo_, 64.0, 32.0, 150.0, 150.0, 0.7, 0);
   }

   void sayWhereMouseIs(in ref ALLEGRO_EVENT event)
   {
      import std.stdio;
      writefln("Mouse at (%s, %s); z = %s", event.mouse.x, event.mouse.y,
               event.mouse.z);
   }

   private ALLEGRO_BITMAP* logo_;
}

void main()
{
   auto engine = new twodee.engine.Engine(640, 480);
   scope(exit)
      delete engine;

   engine.run(new MyState());
}
