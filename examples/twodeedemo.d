

import std.stdio;
import twodee.all;


class MyState: GameState
{
   this()
   {
      updater_ = new Updater();
      guish_ = new GUIshEventGenerator();
      addEventHandler(guish_);
      addEventHandler(updater_);

      bitmap1_ = al_load_bitmap("data/flag_1.png");
      bitmap2_ = al_load_bitmap("data/flag_2.png");
      bitmap3_ = al_load_bitmap("data/flag_3.png");

      sprite_ = new Sprite(64, 64);
      sprite_.addBitmap(bitmap1_);
      sprite_.addBitmap(bitmap2_);
      sprite_.addBitmap(bitmap1_);
      sprite_.addBitmap(bitmap3_);

      sprite_.x = 200;
      sprite_.y = 200;

      font_ = al_load_ttf_font("data/bluehigl.ttf", 50, 0);
      text_ = new Text(font_, "Hi! Âçënts, tóô!");
      text_.alignment = Text.Alignment.RIGHT;
      text_.x = 400;
      text_.y = 25;

      //addEventCallback(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
      addEventCallback(ALLEGRO_EVENT_MOUSE_BUTTON_DOWN, &startAnimation);

      guish_.addEventCallback(
         sprite_, EventType.MOUSE_ENTER,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse enter!");
         });

      guish_.addEventCallback(
         sprite_, EventType.MOUSE_LEAVE,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse leave!");
         });

      guish_.addEventCallback(
         sprite_, EventType.MOUSE_MOVE,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse move!");
         });

      guish_.addEventCallback(
         sprite_, EventType.MOUSE_UP,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse up!");
         });

      guish_.addEventCallback(
         sprite_, EventType.MOUSE_DOWN,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse down!");
         });

      guish_.addEventCallback(
         sprite_, EventType.CLICK,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Click!");
         });

      guish_.addEventCallback(
         sprite_, EventType.DOUBLE_CLICK,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Double click!");
         });
   }

   void onDraw()
   {
      al_clear_to_color(al_map_rgb(200, 200, 0));
      text_.draw();
      sprite_.draw();
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

   private ALLEGRO_FONT* font_;
   private ALLEGRO_BITMAP* bitmap1_;
   private ALLEGRO_BITMAP* bitmap2_;
   private ALLEGRO_BITMAP* bitmap3_;

   private Text text_;

   private GUIshEventGenerator guish_;
}


void main()
{
   auto engine = Engine(640, 480);
   engine.run(new MyState());
}
