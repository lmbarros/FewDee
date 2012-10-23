

import allegro5.allegro;

import twodee.engine;
import twodee.game_state;
import twodee.state_manager;
import twodee.sprite;
import twodee.updater;


class MyState: GameState
{
   this()
   {
      updater_ = new Updater();

      sprite_ = new Sprite(64, 64);
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_2.png");
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_3.png");

      addEventHandler(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
      addEventHandler(ALLEGRO_EVENT_MOUSE_BUTTON_DOWN, &startAnimation);
   }

   void onTick(double deltaTime)
   {
      updater_.tick(deltaTime);
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

   void startAnimation(in ref ALLEGRO_EVENT event)
   {
      double totalTime = 0.0;
      updater_.add(
         delegate(double deltaT)
         {
            totalTime += deltaT;
            immutable size_t dt = cast(size_t)(totalTime * 5);
            sprite_.currentIndex = dt % 4;

            return totalTime < 2.0;
         });
   }

   private Updater updater_;

   private Sprite sprite_;
}


void main()
{
   auto engine = new twodee.engine.Engine(640, 480);
   scope(exit)
      delete engine;

   engine.run(new MyState());
}
