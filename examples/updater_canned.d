/**
 * Example showing the use of the canned updaters.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.functional;
import fewdee.all;


immutable WIDTH = 640;
immutable HEIGHT = 480;

class TheState: GameState
{
   this()
   {
      // Initialize stuff
      bitmap_ = al_load_bitmap("data/small_cloud.png");
      enforce(bitmap_ !is null);

      sprite_ = new Sprite(64, 64, 32, 32);
      enforce(sprite_ !is null);
      sprite_.addBitmap(bitmap_);

      updater_ = new Updater();
      enforce(updater_ !is null);
      addEventHandler(updater_);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          switch (event.keyboard.keycode)
                          {
                             case ALLEGRO_KEY_ESCAPE:
                             {
                                popState();
                                break;
                             }

                             case ALLEGRO_KEY_1:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 500.0, 300.0, 5.0,
                                   &MakeLinearInterpolator);
                                break;
                             }

                             case ALLEGRO_KEY_2:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 110, 240, 5,
                                   &MakeQuarticInOutInterpolator);
                                break;
                             }

                             case ALLEGRO_KEY_3:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 600, 60, 5,
                                   MakeGenericElasticInOutInterpolatorMaker());
                                break;
                             }

                             default:
                                break; // do nothing
                          }
                       });
   }

   ~this()
   {
      al_destroy_bitmap(bitmap_);
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb_f(0.3, 0.4, 1.0));
      sprite_.draw();
   }

   private ALLEGRO_BITMAP* bitmap_;
   private Sprite sprite_;
   private Updater updater_;
}

void main()
{
   auto engine = Engine(WIDTH, HEIGHT);
   engine.run(new TheState());
}
