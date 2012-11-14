/**
 * Some parallax scrolling, used to test scene graph z-order.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.random;
import twodee.all;


immutable WIDTH = 640;
immutable HEIGHT = 480;

class TheState: GameState
{
   this()
   {
      // Create the bitmaps
      bmpStar_ = al_load_bitmap("data/little_star.png");
      enforce(bmpStar_ !is null);

      bmpSmallCloud_ = al_load_bitmap("data/small_cloud.png");
      enforce(bmpSmallCloud_ !is null);

      bmpLargeCloud_ = al_load_bitmap("data/large_cloud.png");
      enforce(bmpLargeCloud_ !is null);

      bmpWitch_ = al_load_bitmap("data/witch.png");
      enforce(bmpWitch_ !is null);

      // Create the scene graph root
      root_ = new Group();

      // Create a bunch of stars
      Sprite[] stars;
      foreach(i; 0..100)
      {
         auto s = new Sprite(8, 8, 4, 4);
         s.addBitmap(bmpStar_);
         s.x = uniform(0, WIDTH);
         s.y = uniform(0, HEIGHT);
         s.z = -2.0;
         stars ~= s;
         root_.addChild(s);
      }

      // Create some small clouds
      Sprite[] smallClouds;
      foreach(i; 0..10)
      {
         auto s = new Sprite(64, 64, 32, 32);
         s.addBitmap(bmpSmallCloud_);
         s.x = uniform(0, WIDTH);
         s.y = uniform(0, HEIGHT);
         s.z = -1.0;
         smallClouds ~= s;
         root_.addChild(s);
      }

      // Create a few large clouds
      Sprite[] largeClouds;
      foreach(i; 0..3)
      {
         auto s = new Sprite(256, 256, 128, 128);
         s.addBitmap(bmpLargeCloud_);
         s.x = uniform(0, WIDTH);
         s.y = uniform(0, HEIGHT);
         s.z = 1.0;
         largeClouds ~= s;
         root_.addChild(s);
      }

      // Create the one and only witch
      auto sprWitch = new Sprite(64, 64, 32, 32);
      sprWitch.addBitmap(bmpWitch_);
      sprWitch.x = WIDTH / 2;
      sprWitch.y = HEIGHT / 2;
      sprWitch.z = 0.0;
      root_.addChild(sprWitch);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });

      // Animate!
      double time = 0;

      enum starSpeed = 5;
      enum smallCloudSpeed = 25;
      enum largeCloudSpeed = 60;

      enum timeToCreateStar = 1.3;
      enum timeToCreateSmallCloud = 5.5;
      enum timeToCreateLargeCloud = 10.0;

      double starCountdown = timeToCreateStar;
      double smallCloudCountdown = timeToCreateSmallCloud;
      double largeCloudCountdown = timeToCreateLargeCloud;

      addEventCallback(TWODEE_EVENT_TICK,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          auto dt = event.user.deltaTime;
                          time += dt;

                          // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                          starCountdown -= dt;
                          smallCloudCountdown -= dt;
                          largeCloudCountdown -= dt;
                          // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

                          foreach(s; stars)
                          {
                             s.x = s.x - starSpeed * dt;
                          }

                          foreach(s; smallClouds)
                          {
                             s.x = s.x - smallCloudSpeed * dt;
                          }

                          foreach(s; largeClouds)
                          {
                             s.x = s.x - largeCloudSpeed * dt;
                          }

                          // sprSun.currentIndex = cast(int)(time*10) % 2;

                          // srtPlanet.r = srtPlanet.r + event.user.deltaTime;
                          // srtMoon.r = srtMoon.r + event.user.deltaTime*3;
                       });
   }

   ~this()
   {
      al_destroy_bitmap(bmpStar_);
      al_destroy_bitmap(bmpSmallCloud_);
      al_destroy_bitmap(bmpLargeCloud_);
      al_destroy_bitmap(bmpWitch_);
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(64, 64, 128));

      auto dv = new DrawingVisitor();
      root_.accept(dv);
      dv.draw();
   }

   private ALLEGRO_BITMAP* bmpStar_;
   private ALLEGRO_BITMAP* bmpSmallCloud_;
   private ALLEGRO_BITMAP* bmpLargeCloud_;
   private ALLEGRO_BITMAP* bmpWitch_;

   private Group root_;
}

void main()
{
   auto engine = Engine(WIDTH, HEIGHT);
   engine.run(new TheState());
}
