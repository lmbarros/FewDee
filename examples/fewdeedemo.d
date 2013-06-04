

import std.stdio;
import fewdee.all;


class MyState: GameState
{
   this()
   {
      updater_ = new Updater();
      guish_ = new GUIshEventGenerator();
      addEventHandler(guish_);
      addEventHandler(updater_);

      ResourceManager.bitmaps.add("bmp1", new Bitmap("data/flag_1.png"));
      ResourceManager.bitmaps.add("bmp2", new Bitmap("data/flag_2.png"));
      ResourceManager.bitmaps.add("bmp3", new Bitmap("data/flag_3.png"));

      sprite_ = new Sprite(64, 64, 6, 61);
      sprite_.addBitmap(ResourceManager.bitmaps["bmp1"]);
      sprite_.addBitmap(ResourceManager.bitmaps["bmp2"]);
      sprite_.addBitmap(ResourceManager.bitmaps["bmp1"]);
      sprite_.addBitmap(ResourceManager.bitmaps["bmp3"]);

      sprite_.x = 200;
      sprite_.y = 200;

      sprite_.scaleX = 2.0;
      sprite_.scaleY = 3.0;

      sprite_.color = al_map_rgba_f(1.0, 1.0, 1.0, 0.2);

      ResourceManager.fonts.add("font", new Font("data/bluehigl.ttf", 50));

      text_ = new Text(ResourceManager.fonts["font"], "Hi! Âçënts, tóô!");
      text_.alignment = Text.Alignment.RIGHT;
      text_.x = 400;
      text_.y = 25;
      text_.color = al_map_rgba_f(0.2, 0.8, 0.2, 0.5);

      //addEventCallback(ALLEGRO_EVENT_MOUSE_AXES, &sayWhereMouseIs);
      addEventCallback(ALLEGRO_EVENT_MOUSE_BUTTON_DOWN, &startAnimation);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });

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

   public override void onDraw()
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
            sprite_.rotation = sprite_.rotation + deltaT;

            return totalTime < 2.0;
         });
   }

   private Updater updater_;

   private Sprite sprite_;

   private Text text_;

   private GUIshEventGenerator guish_;
}


void main()
{
   scope crank = new Crank();
   DisplayManager.createDisplay("default");

   Engine.run(new MyState());
}
