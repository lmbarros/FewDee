/**
 * Some parallax scrolling, used to test scene graph z-order.
 *
 * If the goal were to simply create a parallax scrolling effect like this, it
 * would be more efficient (and I'd say that just as elegant) to not use the
 * scene graph facilities: simply drawing the things in the order of their
 * layers would do the trick. But I wanted some example to ensure that the scene
 * graph rendering was respecting the z-order and this was the first thing I
 * tought of.
 *
 * Authors: Leandro Motta Barros
 */

import std.algorithm;
import std.exception;
import std.random;
import twodee.all;


enum WIDTH = 640;
enum HEIGHT = 480;

enum STAR_SIZE = 8;
enum SMALL_CLOUD_SIZE = 64;
enum LARGE_CLOUD_SIZE = 256;
enum WITCH_SIZE = 64;


class TheState: GameState
{
   this()
   {
      Sprite[] stars;
      Sprite[] smallClouds;
      Sprite[] largeClouds;

      void addStar(float x)
      {
         auto s = new Sprite(STAR_SIZE, STAR_SIZE, STAR_SIZE/2, STAR_SIZE/2);
         s.addBitmap(bmpStar_);
         s.x = x;
         s.y = uniform(0, HEIGHT);
         s.z = -2.0;
         stars ~= s;
         root_.addChild(s);
      }

      void addSmallCloud(float x)
      {
         immutable sz = SMALL_CLOUD_SIZE;
         immutable halfSz = SMALL_CLOUD_SIZE / 2;
         auto s = new Sprite(sz, sz, halfSz, halfSz);
         s.addBitmap(bmpSmallCloud_);
         s.x = x;
         s.y = uniform(0, HEIGHT);
         s.z = -1.0;
         smallClouds ~= s;
         root_.addChild(s);
      }

      void addLargeCloud(float x)
      {
         immutable sz = LARGE_CLOUD_SIZE;
         immutable halfSz = LARGE_CLOUD_SIZE / 2;
         auto s = new Sprite(sz, sz, halfSz, halfSz);
         s.addBitmap(bmpLargeCloud_);
         s.x = x;
         s.y = uniform(0, HEIGHT);
         s.z = 1.0;
         largeClouds ~= s;
         root_.addChild(s);
      }

      // Create the bitmaps
      bmpStar_ = al_load_bitmap("data/little_star.png");
      enforce(bmpStar_ !is null);

      bmpSmallCloud_ = al_load_bitmap("data/small_cloud.png");
      enforce(bmpSmallCloud_ !is null);

      bmpLargeCloud_ = al_load_bitmap("data/large_cloud.png");
      enforce(bmpLargeCloud_ !is null);

      bmpWitch_ = al_load_bitmap("data/witch.png");
      enforce(bmpWitch_ !is null);

      // Create the scene graph
      root_ = new twodee.sg.group.Group();

      foreach(i; 0..3)
         addLargeCloud(uniform(0, WIDTH));

      foreach(i; 0..10)
         addSmallCloud(uniform(0, WIDTH));

      foreach(i; 0..100)
         addStar(uniform(0, WIDTH));

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

      enum timeToCreateStar = 0.953;
      enum timeToCreateSmallCloud = 2.5;
      enum timeToCreateLargeCloud = 5.0;

      auto starCountdown = timeToCreateStar;
      auto smallCloudCountdown = timeToCreateSmallCloud;
      auto largeCloudCountdown = timeToCreateLargeCloud;

      addEventCallback(TWODEE_EVENT_TICK,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          auto dt = event.user.deltaTime;
                          time += dt;
                          starCountdown -= dt;
                          smallCloudCountdown -= dt;
                          largeCloudCountdown -= dt;

                          // Create new objects
                          if (starCountdown <= 0.0)
                          {
                             starCountdown = uniform(
                                timeToCreateStar / 2,
                                timeToCreateStar * 2);
                             addStar(WIDTH + STAR_SIZE);
                          }

                          if (smallCloudCountdown <= 0.0)
                          {
                             smallCloudCountdown = uniform(
                                timeToCreateSmallCloud / 2,
                                timeToCreateSmallCloud * 2);
                             addSmallCloud(WIDTH + SMALL_CLOUD_SIZE);
                          }

                          if (largeCloudCountdown <= 0.0)
                          {
                             largeCloudCountdown = uniform(
                                timeToCreateLargeCloud / 2,
                                timeToCreateLargeCloud * 2);
                             addLargeCloud(WIDTH + LARGE_CLOUD_SIZE);
                          }

                          // Update stars
                          foreach(s; stars)
                          {
                             s.x = s.x - starSpeed * dt;
                             if (s.x + STAR_SIZE < 0.0)
                                s.makeOrphan();
                          }

                          stars = std.algorithm.remove
                             !((a){ return (a.x + STAR_SIZE < 0.0);},
                               SwapStrategy.unstable)
                             (stars);

                          // Update small clouds
                          foreach (s; smallClouds)
                          {
                             s.x = s.x - smallCloudSpeed * dt;
                             if (s.x + SMALL_CLOUD_SIZE < 0.0)
                                s.makeOrphan();
                          }

                          smallClouds = std.algorithm.remove
                             !((a){ return (a.x + SMALL_CLOUD_SIZE < 0.0);},
                               SwapStrategy.unstable)
                             (smallClouds);

                          // Update large clouds
                          foreach (s; largeClouds)
                          {
                             s.x = s.x - largeCloudSpeed * dt;
                             if (s.x + LARGE_CLOUD_SIZE < 0.0)
                                s.makeOrphan();
                          }

                          largeClouds = std.algorithm.remove
                             !((a){ return (a.x + LARGE_CLOUD_SIZE < 0.0);},
                               SwapStrategy.unstable)
                             (largeClouds);
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

   private twodee.sg.group.Group root_;
}

void main()
{
   auto engine = Engine(WIDTH, HEIGHT);
   engine.run(new TheState());
}
