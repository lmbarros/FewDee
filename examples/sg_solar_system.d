/**
 * The good and old solar system graphics programming exercise, now in TwoDee!
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import twodee.all;


immutable WIDTH = 640;
immutable HEIGHT = 480;

class TheState: GameState
{
   this()
   {
      // Create the bitmaps
      bmpAll_ = al_load_bitmap("data/solar_system.png");
      enforce(bmpAll_ !is null);

      bmpSun1_ = al_create_sub_bitmap(bmpAll_, 0, 0, 64, 64);
      enforce(bmpSun1_ !is null);

      bmpSun2_ = al_create_sub_bitmap(bmpAll_, 64, 0, 64, 64);
      enforce(bmpSun2_ !is null);

      bmpPlanet_ = al_create_sub_bitmap(bmpAll_, 128, 0, 64, 64);
      enforce(bmpPlanet_ !is null);

      bmpMoon_ = al_create_sub_bitmap(bmpAll_, 192, 0, 64, 64);
      enforce(bmpMoon_ !is null);

      // Create the scene graph

      //              srtRoot_
      //              /      \
      //          srtPlanet  sprSun
      //          /      \
      //     srtMoon    sprPlanet
      //        |
      //     sprMoon

      srtRoot_ = new SRT();
      auto srtPlanet = new SRT();
      auto srtMoon = new SRT();
      auto sprSun = new Sprite(64, 64, 32, 32);
      auto sprPlanet = new Sprite(64, 64, 32, 32);
      auto sprMoon = new Sprite(64, 64, 32, 32);

      srtRoot_.addChild(srtPlanet);
      srtRoot_.addChild(sprSun);
      srtPlanet.addChild(srtMoon);
      srtPlanet.addChild(sprPlanet);
      srtMoon.addChild(sprMoon);

      sprSun.addBitmap(bmpSun1_);
      sprSun.addBitmap(bmpSun2_);

      srtRoot_.tx = WIDTH / 2.0;
      srtRoot_.ty = HEIGHT / 2.0;

      sprPlanet.addBitmap(bmpPlanet_);
      srtPlanet.tx = 200;

      sprMoon.addBitmap(bmpMoon_);
      srtMoon.tx = 60;

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });

      // Animate!
      double time = 0;

      addEventCallback(TWODEE_EVENT_TICK,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          time += event.user.deltaTime;
                          sprSun.currentIndex = cast(int)(time*10) % 2;

                          srtPlanet.r = srtPlanet.r + event.user.deltaTime;
                          srtMoon.r = srtMoon.r + event.user.deltaTime*3;
                       });
   }

   ~this()
   {
      al_destroy_bitmap(bmpSun1_);
      al_destroy_bitmap(bmpSun2_);
      al_destroy_bitmap(bmpPlanet_);
      al_destroy_bitmap(bmpMoon_);
      al_destroy_bitmap(bmpAll_);
   }

   public void onDraw()
   {
      al_clear_to_color(al_map_rgb(16, 16, 32));

      auto dv = new DrawingVisitor();
      srtRoot_.accept(dv);
      dv.draw();
   }

   private ALLEGRO_BITMAP* bmpAll_;
   private ALLEGRO_BITMAP* bmpSun1_;
   private ALLEGRO_BITMAP* bmpSun2_;
   private ALLEGRO_BITMAP* bmpPlanet_;
   private ALLEGRO_BITMAP* bmpMoon_;

   private SRT srtRoot_;
}

void main()
{
   auto engine = Engine(WIDTH, HEIGHT);
   engine.run(new TheState());
}