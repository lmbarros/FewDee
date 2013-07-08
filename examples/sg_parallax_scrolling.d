/**
 * FewDee's "Parallax Scrolling Scene Graph" example.
 *
 * This is intended to test scene graph z-order.
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
import fewdee.all;

// We'll use these to position things on the screen.
enum WIDTH = 640;
enum HEIGHT = 480;

// The sizes of the objects we'll show on the screen.
enum STAR_SIZE = 8;
enum SMALL_CLOUD_SIZE = 64;
enum LARGE_CLOUD_SIZE = 256;
enum WITCH_SIZE = 64;


void main()
{
   // Start the engine.
   scope crank = new fewdee.engine.Crank();

   // When this is set to 'true', we'll exit the main loop.
   bool exitPlease = false;

   // Initialize the resources we'll use. We are not using the 'ResourceManager'
   // here, so we'll have to release these resources manually when the program
   // ends.
   auto bmpStar = new Bitmap("data/little_star.png");
   auto bmpSmallCloud = new Bitmap("data/small_cloud.png");
   auto bmpLargeCloud = new Bitmap("data/large_cloud.png");
   auto bmpWitch = new Bitmap("data/witch.png");

   // We'll a large (and varying!) number of stars, small clouds and large
   // clouds. So, let's create some dynamic arrays to store them
   Sprite[] stars;
   Sprite[] smallClouds;
   Sprite[] largeClouds;

   // Create the scene graph root. Our scene graph will not be particularly
   // interesting: just a root node with all other nodes directly attached to
   // it.
   auto root = new fewdee.sg.group.Group();

   // We'll need to create stars and clouds all the time. Here we define some
   // handy functions to create these objects whenever we need them. All of
   // these helper functions take a single parameter, which is the position of
   // the object along the horizontal axis (when the program is already running,
   // all objects will be created slightly beyond the screen's right corned, out
   // of the user view; but when firstly populating the scene, we want stars and
   // clouds all over the screen).
   //
   // Each of the helper functions creates a new Sprite, adds the proper bitmap
   // to it, sets its position (including the 'z' coordinate, which determines
   // the drawing order and is what we are testing here), adds it to the
   // proper array of objects and adds it as a child of the scene graph root.
   void addStar(float x)
   {
      auto s = new Sprite(STAR_SIZE, STAR_SIZE, STAR_SIZE/2, STAR_SIZE/2);
      s.addBitmap(bmpStar);
      s.x = x;
      s.y = uniform(0, HEIGHT);
      s.z = -2.0;
      stars ~= s;
      root.addChild(s);
   }

   void addSmallCloud(float x)
   {
      immutable sz = SMALL_CLOUD_SIZE;
      immutable halfSz = SMALL_CLOUD_SIZE / 2;
      auto s = new Sprite(sz, sz, halfSz, halfSz);
      s.addBitmap(bmpSmallCloud);
      s.x = x;
      s.y = uniform(0, HEIGHT);
      s.z = -1.0;
      smallClouds ~= s;
      root.addChild(s);
   }

   void addLargeCloud(float x)
   {
      immutable sz = LARGE_CLOUD_SIZE;
      immutable halfSz = LARGE_CLOUD_SIZE / 2;
      auto s = new Sprite(sz, sz, halfSz, halfSz);
      s.addBitmap(bmpLargeCloud);
      s.x = x;
      s.y = uniform(0, HEIGHT);
      s.z = 1.0;
      largeClouds ~= s;
      root.addChild(s);
   }

   // Now, add the initial set clouds (both large and small clouds) and
   // stars. Since we want them distributed around all the screen, we pass a
   // random number as parameter to the helper functions (this is the horizontal
   // coordinate).
   foreach(i; 0..3)
      addLargeCloud(uniform(0, WIDTH));

   foreach(i; 0..10)
      addSmallCloud(uniform(0, WIDTH));

   foreach(i; 0..100)
      addStar(uniform(0, WIDTH));

   // Now, create a sprite for the witch, which will remain always in the center
   // of the screen.
   auto sprWitch = new Sprite(64, 64, 32, 32);
   sprWitch.addBitmap(bmpWitch);
   sprWitch.x = WIDTH / 2;
   sprWitch.y = HEIGHT / 2;
   sprWitch.z = 0.0;
   root.addChild(sprWitch);

   // Quit if ESC is pressed
   EventManager.addHandler(
      ALLEGRO_EVENT_KEY_DOWN,
      delegate(in ref ALLEGRO_EVENT event)
      {
         if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
            exitPlease = true;
      });

   // Time to animate. The time variable will be incremented as "tick" events
   // are triggered.

   // These are the speeds (in pixels per second) of each of the types of
   // objects we have.
   enum starSpeed = 5;
   enum smallCloudSpeed = 25;
   enum largeCloudSpeed = 60;

   // These are used to determine the time intervals between the creation of
   // objects. The higher the number, the higher the interval between the
   // creation of objects of the corresponding type. (As you'll see below, the
   // actual intervals have a random factor, to avoid making things too regular;
   // the values defined here are just a rough specification of the actual
   // intervals used.)
   enum timeToCreateStar = 0.953;
   enum timeToCreateSmallCloud = 2.5;
   enum timeToCreateLargeCloud = 5.0;

   // And these are the variables used to control how much time we still have to
   // wait until creating a new object. When one of those "counters" gets to
   // zero, one instance of the corresponding object is created.
   auto starCountdown = timeToCreateStar;
   auto smallCloudCountdown = timeToCreateSmallCloud;
   auto largeCloudCountdown = timeToCreateLargeCloud;

   // Add an event handler for "tick" events. All state is updated here.
   EventManager.addHandler(
      FEWDEE_EVENT_TICK,
      delegate(in ref ALLEGRO_EVENT event)
      {
         // Decrement the "counters" used to determine if it is already time to
         // create new objects.
         auto dt = event.user.deltaTime;
         starCountdown -= dt;
         smallCloudCountdown -= dt;
         largeCloudCountdown -= dt;

         // If the "counters" got to zero, create a new object and reset the
         // counter. Notice that the "timeToCreate" constants we create above
         // are used together with a random distribution to generate the time of
         // the next object creation.
         if (starCountdown <= 0.0)
         {
            starCountdown = uniform(timeToCreateStar / 2, timeToCreateStar * 2);
            addStar(WIDTH + STAR_SIZE);
         }

         if (smallCloudCountdown <= 0.0)
         {
            smallCloudCountdown =
               uniform(timeToCreateSmallCloud / 2, timeToCreateSmallCloud * 2);
            addSmallCloud(WIDTH + SMALL_CLOUD_SIZE);
         }

         if (largeCloudCountdown <= 0.0)
         {
            largeCloudCountdown =
               uniform(timeToCreateLargeCloud / 2, timeToCreateLargeCloud * 2);
            addLargeCloud(WIDTH + LARGE_CLOUD_SIZE);
         }

         // Update stars: move each one to the left (at the proper speed), and,
         // if they went beyond the left screen corner, remove them from the
         // scene graph ('makeOrphan()') and from the array of objects
         // ('std.algorithm.remove()').
         foreach(s; stars)
         {
            s.x = s.x - starSpeed * dt;
            if (s.x + STAR_SIZE < 0.0)
               s.makeOrphan();
         }

         stars = std.algorithm.remove!(
            a => a.x + STAR_SIZE < 0.0, SwapStrategy.unstable)
            (stars);

         // Update small clouds.
         foreach (s; smallClouds)
         {
            s.x = s.x - smallCloudSpeed * dt;
            if (s.x + SMALL_CLOUD_SIZE < 0.0)
               s.makeOrphan();
         }

         smallClouds = std.algorithm.remove!(
            a => a.x + SMALL_CLOUD_SIZE < 0.0, SwapStrategy.unstable)
            (smallClouds);

         // Update large clouds
         foreach (s; largeClouds)
         {
            s.x = s.x - largeCloudSpeed * dt;
            if (s.x + LARGE_CLOUD_SIZE < 0.0)
               s.makeOrphan();
         }

         largeClouds = std.algorithm.remove!(
            a => a.x + LARGE_CLOUD_SIZE < 0.0, SwapStrategy.unstable)
            (largeClouds);
      });

   // And draw, by calling 'fewdee.sg.drawing_visitor.draw()'. Under the hood,
   // this handy function instantiates a 'DrawingVisitor', makes it visit the
   // scene graph, and more.
   EventManager.addHandler(
      FEWDEE_EVENT_DRAW,
      delegate(in ref ALLEGRO_EVENT event)
      {
         al_clear_to_color(al_map_rgb(64, 64, 128));
         root.draw(); // fewdee.sg.drawing_visitor.draw()
      });

   // Create a display
   DisplayManager.createDisplay("main");

   // Run the main loop while 'exitPlease' is true.
   Engine.run(() => !exitPlease);
}
