/**
 * A quick and dirty FewDee demo. Should be removed once I have better examples
 * for everything.
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;


void main()
{
   al_run_allegro(
   {
      // Start the engine and "accessories"
      scope crank = new fewdee.engine.Crank();
      scope updater = new TickBasedUpdater();
      scope neg = new NodeEventsGenerator();

      // Load the resources
      ResourceManager.bitmaps.add("bmp1", new Bitmap("data/flag_1.png"));
      ResourceManager.bitmaps.add("bmp2", new Bitmap("data/flag_2.png"));
      ResourceManager.bitmaps.add("bmp3", new Bitmap("data/flag_3.png"));
      ResourceManager.fonts.add("font", new Font("data/bluehigl.ttf", 50));

      // Create a sprite
      auto sprite = new SpriteNode(64, 64, 6, 61);
      sprite.addBitmap(ResourceManager.bitmaps["bmp1"]);
      sprite.addBitmap(ResourceManager.bitmaps["bmp2"]);
      sprite.addBitmap(ResourceManager.bitmaps["bmp1"]);
      sprite.addBitmap(ResourceManager.bitmaps["bmp3"]);
      sprite.x = 200;
      sprite.y = 200;
      sprite.scaleX = 2.0;
      sprite.scaleY = 3.0;
      sprite.color = al_map_rgba_f(0.2, 0.2, 0.2, 0.2);

      // Create a text
      auto text = new Text(ResourceManager.fonts["font"], "Hi! Âçënts, tóô!");
      text.alignment = Text.Alignment.RIGHT;
      text.x = 400;
      text.y = 25;
      text.color = al_map_rgba_f(0.1, 0.4, 0.1, 0.5);

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Now register all the event handlers we'll need

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // Animate the flag sprite when the mouse button is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_MOUSE_BUTTON_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            auto totalTime = 0.0;
            updater.add(
               delegate(double deltaT)
               {
                  totalTime += deltaT;
                  immutable dt = cast(size_t)(totalTime * 5);
                  sprite.currentIndex = dt % 4;
                  sprite.rotation = sprite.rotation + deltaT;
                  return totalTime < 2.0;
               });
         });

      // Print stuff to the console as node events are generated
      neg.addHandler(
         sprite, EventType.MOUSE_ENTER,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse enter!");
         });

      neg.addHandler(
         sprite, EventType.MOUSE_LEAVE,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse leave!");
         });

      neg.addHandler(
         sprite, EventType.MOUSE_MOVE,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse move!");
         });

      neg.addHandler(
         sprite, EventType.MOUSE_UP,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse up!");
         });

      neg.addHandler(
         sprite, EventType.MOUSE_DOWN,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Mouse down!");
         });

      neg.addHandler(
         sprite, EventType.CLICK,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Click!");
         });

      neg.addHandler(
         sprite, EventType.DOUBLE_CLICK,
         delegate(in ref ALLEGRO_EVENT event, Node node)
         {
            writeln("Double click!");
         });

      // And draw!
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(200, 200, 0));
            text.draw();
            sprite.draw();
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // We're done!
      return 0;
   });
}
