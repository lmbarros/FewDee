/**
 * An example showing how to use sprite animation events.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;

// Sprite animation events are events generated as sprite animations enter
// certain frames. This example shows how to use them. We'll display a group of
// 10 stick men; pressing keys 0-9 will make each of them to play a clap
// animation. The nice part is that we'll say that we want an event generated
// whenever the clap animation reaches the frame where both hand touch. Then,
// we'll handle this event, and play a clap sound in response to it. Voilà! A
// nice way to synchronize a sprite animation with audio.

void main()
{
   al_run_allegro(
   {
      // Start the engine and "accessories"
      scope crank = new fewdee.engine.Crank();
      scope updater = new TickBasedUpdater();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Initialize the resources we'll use.
      auto bmpStickMan = new Bitmap("data/stick_man.png");
      auto sndClap = new AudioSample("data/clap.ogg");

      // Create a 'SpriteType'.
      scope sptStickMan = new SpriteType(64, 64);

      sptStickMan.addImage(bmpStickMan, 0, 0);
      sptStickMan.addImage(bmpStickMan, 64, 0);
      sptStickMan.addImage(bmpStickMan, 128, 0);
      sptStickMan.addImage(bmpStickMan, 192, 0);
      sptStickMan.addImage(bmpStickMan, 0, 64);
      sptStickMan.addImage(bmpStickMan, 64, 64);
      sptStickMan.addImage(bmpStickMan, 128, 64);
      sptStickMan.addImage(bmpStickMan, 192, 64);

      sptStickMan.addAnimation("clap",
                               SpriteType.Frame(6, 0.3),
                               SpriteType.Frame(0, 0.2),
                               SpriteType.Frame(7, 0.2),
                               SpriteType.Frame(0, 0.2));

      // This is where we create the sprite animation event. We are saying at,
      // when reaching the frame 2 of the "clap" animation, we want to generate
      // a sprite animation event identified by 'strID!"SMClap"' (which is just
      // a fancy way to represent an integer value in a more mnemonic way:
      // SMClap is for "stick man clap"). Notice "frame 2" is the third frame,
      // because the frame numbering starts at zero.
      sptStickMan.addAnimationEvent("clap", 2, strID!"SMClap");

      // Let's create our army of stick men.
      scope Sprite sprStickMan[10];
      foreach(i; 0..10)
      {
         sprStickMan[i] = new Sprite(sptStickMan);
         sprStickMan[i].x = 50 + i * 50;
         sprStickMan[i].y = 100;
      }

      // This is just to map a number from 0 to 9 to another number in the same
      // range. The idea is to map the keys in the row of number keys in the
      // keyboard to the corresponding array position. So, the first key ("1")
      // gets mapped to the first array position (0), the second key ("2") to
      // the second array position (1) and the last key ("0") gets mapped to the
      // last array position (9).
      pure size_t indexFromSequence(int seq)
      {
         if (seq == 0)
            return 9;
         else
            return seq - 1;
      }

      // And now, add event handlers.
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            switch (event.keyboard.keycode)
            {
               // Quit if ESC is pressed
               case ALLEGRO_KEY_ESCAPE:
               {
                  exitPlease = true;
                  break;
               }

               // Clap the corresponding stick man when pressing number keys. We
               // don't do anything special here, this is just a regular sprite
               // animation playing. Events will be generated automatically
               // because we added them to the sprite type.
               case ALLEGRO_KEY_0: .. case ALLEGRO_KEY_9:
               {
                  auto i = indexFromSequence(
                     event.keyboard.keycode - ALLEGRO_KEY_0);

                  updater.addAnimation(sprStickMan[i], "clap");

                  break;
               }

               default:
                  break; // do nothing
            }
         });


      // And here we add a handler to the sprite animation event. We simply
      // check if the event has the ID we expect (strID!"SMClap"), and, if this
      // is the case, we play a clapping sound.
      EventManager.addHandler(
         FEWDEE_EVENT_SPRITE_ANIMATION,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.user.spriteAnimationEventID == strID!"SMClap")
            {
               // Just to be fancy (and to show that a reference to the sprite
               // generating the event is passed in the event data), in addition
               // to playing the clap sound, we set its balance in proportion to
               // the sprite position: sound will play more loudly through the
               // left or right speaker depending on the sprite position on the
               // screen.
               const bal = ((event.user.sprite.x - 50) / 225.0) - 1.0;
               sndClap.play().balance = bal;
            }
         });

      // Finally, set the drawing function. We simply clear the background to
      // white and draw each of the stick men, side-by-side.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb(255, 255, 255));
            foreach (i; 0..10)
               sprStickMan[i].draw();
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // Free resources (using the ResourceManager would be a good idea).
      bmpStickMan.free();
      sndClap.free();

      // We're done!
      return 0;
   });
}
