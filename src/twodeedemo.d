

import allegro5.allegro;

import std.stdio;

import twodee.engine;
import twodee.event;
import twodee.game_state;
import twodee.guish;
import twodee.state_manager;
import twodee.sprite;
import twodee.updater;


class MyState: GameState
{
   this()
   {
      updater_ = new Updater();
      guish_ = new GUIshEventGenerator();

      sprite_ = new Sprite(64, 64);
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_2.png");
      sprite_.addBitmap("data/flag_1.png");
      sprite_.addBitmap("data/flag_3.png");

      sprite_.top = 200;
      sprite_.left = 200;

      //addEventHandler(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
      addEventHandler(ALLEGRO_EVENT_MOUSE_BUTTON_DOWN, &startAnimation);
      addEventHandler(TWODEE_EVENT_TICK, &handleTick);

      guish_.addHandler(sprite_, EventType.MOUSE_ENTER,
                        delegate() { writeln("Mouse enter!"); });

      guish_.addHandler(sprite_, EventType.MOUSE_LEAVE,
                        delegate() { writeln("Mouse leave!"); });

      guish_.addHandler(sprite_, EventType.MOUSE_MOVE,
                        delegate() { writeln("Mouse move!"); });

      guish_.addHandler(sprite_, EventType.MOUSE_UP,
                        delegate() { writeln("Mouse up!"); });

      guish_.addHandler(sprite_, EventType.MOUSE_DOWN,
                        delegate() { writeln("Mouse down!"); });

      guish_.addHandler(sprite_, EventType.CLICK,
                        delegate() { writeln("Click!"); });

      guish_.addHandler(sprite_, EventType.DOUBLE_CLICK,
                        delegate() { writeln("Double click!"); });
   }

   void handleTick(in ref ALLEGRO_EVENT event)
   {
      auto deltaTime = event.user.deltaTime;
      updater_.tick(deltaTime);
   }

   void onDraw()
   {
      al_clear_to_color(al_map_rgb(200, 200, 0));
      sprite_.draw();
   }

   override public void onEvent(in ref ALLEGRO_EVENT event)
   {
      // TODO: This sucks. I shouldn't have to override onEvent to use GUIsh.
      super.onEvent(event);
      guish_.onEvent(event);
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

   private GUIshEventGenerator guish_;
}


void main()
{
   auto engine = new twodee.engine.Engine(640, 480);
   scope(exit)
      delete engine;

   engine.run(new MyState());
}
