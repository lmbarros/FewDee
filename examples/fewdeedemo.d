/**
 * A quick and dirty FewDee demo. Should be removed once I have better examples
 * for everything.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
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
      ResourceManager.fonts.add("font", new Font("data/lato.otf", 50));

      // Create a sprite
      auto spriteType = new SpriteType(64, 64, "bmp1", "bmp2", "bmp3");
      spriteType.setCenter(6, 61);
      spriteType.addAnimation("wave",
                              SpriteType.Frame(1, 0.15),
                              SpriteType.Frame(0, 0.15),
                              SpriteType.Frame(2, 0.15),
                              SpriteType.Frame(0, 0.15));
      auto sprite = new SpriteNode(spriteType);
      sprite.x = 200;
      sprite.y = 200;
      sprite.scaleX = 2.0;
      sprite.scaleY = 3.0;
      sprite.color = al_map_rgba_f(0.2, 0.2, 0.2, 0.2);

      // Create a text
      auto text = new Text(rmFont("font"), "Hi! Âçënts, tóô!");
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
      UpdaterFuncID wavingAnimID = InvalidUpdaterFuncID;
      auto numWavingAnims = 0;

      EventManager.addHandler(
         ALLEGRO_EVENT_MOUSE_BUTTON_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            updater.remove(wavingAnimID);
            wavingAnimID = updater.addAnimation(
               sprite, "wave", 1.0, true);
            ++numWavingAnims;

            auto totalTime = 0.0;
            updater.add(
               delegate(double deltaT)
               {
                  totalTime += deltaT;
                  sprite.rotation = sprite.rotation + deltaT;

                  if (totalTime > 2.0)
                  {
                     if (--numWavingAnims == 0)
                        updater.remove(wavingAnimID);

                     return false;
                  }
                  else
                  {
                     return true;
                  }
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

            rmFont("font").drawBorderedText(
               "This text has a thin border!", 10, 350,
               Color(0.9, 0.9, 0.9, 1.0),
               Color(0.1, 0.1, 0.1, 1.0),
               0.75);

            rmFont("font").drawBorderedText(
               "This text has a thick border!", 10, 400,
               Color(0.9, 0.9, 0.9, 1.0),
               Color(0.1, 0.1, 0.1, 1.0),
               1.8);
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // We're done!
      return 0;
   });
}
