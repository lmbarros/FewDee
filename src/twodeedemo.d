

import allegro5.allegro;

import twodee.engine;
import twodee.game_state;
import twodee.state_manager;
import twodee.sprite;


class MyState: GameState
{
   this()
   {
      sprite_ = new Sprite(64, 64);
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_2.png");
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_3.png");

      addEventHandler(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
   }

   void onTick(double deltaTime)
   {
      immutable size_t dt = cast(size_t)(al_get_time() * 5);
      sprite_.currentIndex = dt % 4;
   }

   void onDraw()
   {
      al_clear_to_color(al_map_rgb(200, 200, 0));
      sprite_.draw(200, 200);
   }

   void sayWhereMouseIs(in ref ALLEGRO_EVENT event)
   {
      import std.stdio;
      writefln("Mouse at (%s, %s); z = %s", event.mouse.x, event.mouse.y,
               event.mouse.z);
   }

   private Sprite sprite_;
}

void main()
{
   auto engine = new twodee.engine.Engine(640, 480);
   scope(exit)
      delete engine;

   engine.run(new MyState());
}
