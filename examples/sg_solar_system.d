/**
 * FewDee's "Solar System Scene Graph" example.
 *
 * The good and old solar system graphics programming exercise, now in FewDee.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import fewdee.all;


// We'll use these to position things on the screen.
immutable WIDTH = 640;
immutable HEIGHT = 480;


void main()
{
   // Start the engine
   scope crank = new fewdee.engine.Crank();

   // When this is set to 'true', we'll exit the main loop.
   bool exitPlease = false;

   // Initialize the only resource we'll use. We are not using the
   // 'ResourceManager' here, so we'll have to release the resources manually
   // when the program ends.
   auto bmpAll = new Bitmap("data/solar_system.png");

   // We have all the resources packed in a single image (a sprite sheet). Here,
   // we use the Allegro API to create sub bitmaps representing the individual
   // images we are interested in using.
   //
   // TODO: This is too low-level. FewDee needs to provide a nicer way to use
   //       sprite sheets.
   auto bmpSun1 = al_create_sub_bitmap(bmpAll, 0, 0, 64, 64);
   enforce(bmpSun1 !is null);

   auto bmpSun2 = al_create_sub_bitmap(bmpAll, 64, 0, 64, 64);
   enforce(bmpSun2 !is null);

   auto bmpPlanet = al_create_sub_bitmap(bmpAll, 128, 0, 64, 64);
   enforce(bmpPlanet !is null);

   auto bmpMoon = al_create_sub_bitmap(bmpAll, 192, 0, 64, 64);
   enforce(bmpMoon !is null);

   // Now, create the scene graph. We want to create a scene graph like the one
   // shown below. The code just create the nodes and connections between nodes.
   //
   //              srtRoot
   //              /      \
   //          srtPlanet  sprSun
   //          /      \
   //     srtMoon    sprPlanet
   //        |
   //     sprMoon

   auto srtRoot = new SRT();
   auto srtPlanet = new SRT();
   auto srtMoon = new SRT();
   auto sprSun = new SpriteNode(64, 64, 32, 32);
   auto sprPlanet = new SpriteNode(64, 64, 32, 32);
   auto sprMoon = new SpriteNode(64, 64, 32, 32);

   srtRoot.addChild(srtPlanet);
   srtRoot.addChild(sprSun);
   srtPlanet.addChild(srtMoon);
   srtPlanet.addChild(sprPlanet);
   srtMoon.addChild(sprMoon);

   sprSun.addBitmap(bmpSun1);
   sprSun.addBitmap(bmpSun2);

   srtRoot.x = WIDTH / 2.0;
   srtRoot.y = HEIGHT / 2.0;

   sprPlanet.addBitmap(bmpPlanet);
   srtPlanet.x = 200;

   sprMoon.addBitmap(bmpMoon);
   srtMoon.x = 60;

   // Time to create event handlers.

   // Quit if ESC is pressed
   EventManager.addHandler(
      ALLEGRO_EVENT_KEY_DOWN,
      delegate(in ref ALLEGRO_EVENT event)
      {
         if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
            exitPlease = true;
      });

   // Animate! In response to "tick" events, we update the rotations of the
   // celestial bodies nodes. (And we also alternate between the two sun
   // images, for a poor man's glowing effect.)
   auto time = 0.0;
   EventManager.addHandler(
      FEWDEE_EVENT_TICK,
      delegate(in ref ALLEGRO_EVENT event)
      {
         auto dt = event.user.deltaTime;
         time += dt;
         sprSun.currentIndex = cast(int)(time*10) % 2;

         srtPlanet.rotation = srtPlanet.rotation + dt;
         srtMoon.rotation = srtMoon.rotation + dt * 3;
      });

   // And draw, by calling 'fewdee.sg.drawing_visitor.draw()'. Under the hood,
   // this handy function instantiates a 'DrawingVisitor', makes it visit the
   // scene graph, and more.
   EventManager.addHandler(
      FEWDEE_EVENT_TICK,
      delegate(in ref ALLEGRO_EVENT event)
      {
         al_clear_to_color(al_map_rgb(16, 16, 32));
         srtRoot.draw(); // fewdee.sg.drawing_visitor.draw()
      });

   // Create a display
   DisplayManager.createDisplay("main");

   // Run the main loop while 'exitPlease' is true.
   Engine.run(() => !exitPlease);
}
