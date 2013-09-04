/**
 * FewDee's "Solar System Scene Graph" example.
 *
 * The good and old solar system graphics programming exercise, now in FewDee.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
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
   al_run_allegro(
   {
      // Start the engine
      scope crank = new fewdee.engine.Crank();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Initialize the only resource we'll use. We are not using the
      // 'ResourceManager' here, so we'll have to release the resources manually
      // when the program ends.
      auto bmpAll = new Bitmap("data/solar_system.png");

      // We'll use a single 'SpriteType' for all the 'SpriteNode's we'll
      // use. Here it is.
      auto sptCelestialBodies = new SpriteType(64, 64);
      sptCelestialBodies.setCenter(32, 32);
      sptCelestialBodies.addImage(bmpAll, 0, 0);   // sun 1
      sptCelestialBodies.addImage(bmpAll, 64, 0);  // sun 2
      sptCelestialBodies.addImage(bmpAll, 128, 0); // planet
      sptCelestialBodies.addImage(bmpAll, 192, 0); // moon

      // Now, create the scene graph. We want to create a scene graph like the
      // one shown below. The code just create the nodes and connections between
      // nodes.
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

      auto sprSun = new SpriteNode(sptCelestialBodies);
      sprSun.currentImage = 0;

      auto sprPlanet = new SpriteNode(sptCelestialBodies);
      sprPlanet.currentImage = 2;

      auto sprMoon = new SpriteNode(sptCelestialBodies);
      sprMoon.currentImage = 3;

      srtRoot.addChild(srtPlanet);
      srtRoot.addChild(sprSun);
      srtPlanet.addChild(srtMoon);
      srtPlanet.addChild(sprPlanet);
      srtMoon.addChild(sprMoon);

      srtRoot.x = WIDTH / 2.0;
      srtRoot.y = HEIGHT / 2.0;

      srtPlanet.x = 200;

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
            // We are changing the sprite images manually here; we could use a
            // sprite animation to automate this.
            auto dt = event.user.deltaTime;
            time += dt;
            sprSun.currentImage = cast(int)(time*10) % 2;

            srtPlanet.rotation = srtPlanet.rotation + dt;
            srtMoon.rotation = srtMoon.rotation + dt * 3;
         });

      // And draw, by calling 'fewdee.sg.drawing_visitor.draw()'. Under the
      // hood, this handy function instantiates a 'DrawingVisitor', makes it
      // visit the scene graph, and more.
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
      run(() => !exitPlease);

      // Free the one resource we are using.
      bmpAll.free();

      // We're done!
      return 0;
   });
}
