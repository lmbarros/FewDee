/**
 * FewDee's "Canned Audio Updaters" example.
 *
 * This is just like the "Canned Updaters" example, but tests the updaters
 * usable with audio.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.functional;
import std.math;
import std.string;
import fewdee.all;


// This example isn't conceptually different from the 'updater_canned'
// example. I won't repeat myself here, comments will be scarce. Check the other
// example if you have problems understanding anything here.
void main()
{
   al_run_allegro(
   {
      scope crank = new fewdee.engine.Crank();
      scope updater = new TickBasedUpdater();
      bool exitPlease = false;

      auto font = new Font("data/bluehigl.ttf", 26);

      // Lil' function to draw text on the display
      void drawText(string text, float x, float y)
      {
         al_draw_text(font, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                      text.toStringz);
      }

      auto stream = new AudioStream("data/Bassa_Island_Game_Loop.ogg");
      stream.playMode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP;
      stream.play();

      UpdaterFuncID currentGainUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentSpeedUpdater = InvalidUpdaterFuncID;
      UpdaterFuncID currentBalanceUpdater = InvalidUpdaterFuncID;

      // Quit if ESC is pressed
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            switch (event.keyboard.keycode)
            {
               case ALLEGRO_KEY_ESCAPE:
               {
                  exitPlease = true;
                  break;
               }

               // Gain updaters
               case ALLEGRO_KEY_1:
               {
                  updater.remove(currentGainUpdater);
                  currentGainUpdater = updater.addGainUpdater(
                     stream, 0.2, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_Q:
               {
                  updater.remove(currentGainUpdater);
                  currentGainUpdater = updater.addGainUpdater(
                     stream, 1.0, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_A:
               {
                  updater.remove(currentGainUpdater);
                  currentGainUpdater = updater.addGainUpdater(
                     stream, 1.8, 3.5, interpolatorMaker!"t");
                  break;
               }

               // Speed updaters
               case ALLEGRO_KEY_2:
               {
                  updater.remove(currentSpeedUpdater);
                  currentSpeedUpdater = updater.addSpeedUpdater(
                     stream, 0.66, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_W:
               {
                  updater.remove(currentSpeedUpdater);
                  currentSpeedUpdater = updater.addSpeedUpdater(
                     stream, 1.0, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_S:
               {
                  updater.remove(currentSpeedUpdater);
                  currentSpeedUpdater = updater.addSpeedUpdater(
                     stream, 1.33, 3.5, interpolatorMaker!"t");
                  break;
               }

               // Balance updaters
               case ALLEGRO_KEY_3:
               {
                  updater.remove(currentBalanceUpdater);
                  currentBalanceUpdater = updater.addBalanceUpdater(
                     stream, -1.0, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_E:
               {
                  updater.remove(currentBalanceUpdater);
                  currentBalanceUpdater = updater.addBalanceUpdater(
                     stream, 0.0, 3.5, interpolatorMaker!"t");
                  break;
               }

               case ALLEGRO_KEY_D:
               {
                  updater.remove(currentBalanceUpdater);
                  currentBalanceUpdater = updater.addBalanceUpdater(
                     stream, 1.0, 3.5, interpolatorMaker!"t");
                  break;
               }

               // Default
               default:
                  break; // do nothing
            }
         });

      // Draw! We just clear the screen and write some text.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            al_clear_to_color(al_map_rgb_f(0.1, 0.1, 0.1));
            drawText("Pressing some keys will make the audio playing change.",
                     20.0, 240.0);
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // Free the resources
      font.free();
      stream.free();

      // We're done!
      return 0;
   });
}
