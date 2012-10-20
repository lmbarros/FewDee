

import allegro5.allegro;

import twodee.engine;
import twodee.game_state;
import twodee.state_manager;


void main()
{
   auto engine = new twodee.engine.Engine(640, 480);
   scope(exit)
      delete engine;

   al_clear_to_color(al_map_rgb(200, 200, 0));

   auto logo = al_load_bitmap("data/logo.png");
   al_draw_bitmap(logo, 0.0, 0.0, 0);
   al_draw_bitmap(logo, 20.0, 0.0, 0);
   al_draw_bitmap(logo, 120.0, 0.0, 0);

   al_draw_rotated_bitmap(logo, 64.0, 32.0, 150.0, 150.0, 0.7, 0);

   al_flip_display();
   al_rest(10);
}
