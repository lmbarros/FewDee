/**
 * Example showing the use of the canned updaters.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.functional;
import std.math;
import fewdee.all;


immutable WIDTH = 640;
immutable HEIGHT = 480;

class TheState: GameState
{
   this()
   {
      // Initialize stuff
      bitmap_ = AllegroBitmap("data/white_circle.png");
      enforce(bitmap_ !is null);

      sprite_ = new Sprite(64, 64, 32, 32);
      enforce(sprite_ !is null);
      sprite_.addBitmap(bitmap_);
      sprite_.x = WIDTH/2.0;
      sprite_.y = HEIGHT/2.0;

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

                             // Position updaters
                             case ALLEGRO_KEY_1:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 30.0, 30.0, 3.5,
                                   interpolatorMaker!"t");
                                break;
                             }

                             case ALLEGRO_KEY_Q:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 600, 40, 3.5,
                                   interpolatorMaker!"[t^2]");
                                break;
                             }

                             case ALLEGRO_KEY_A:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 530, 410, 6.0,
                                   interpolatorMaker!"elastic]");
                                break;
                             }

                             case ALLEGRO_KEY_Z:
                             {
                                updater_.addPositionUpdater(
                                   sprite_, 55, 430, 2.0,
                                   interpolatorMaker!"[bounce");
                                break;
                             }

                             // Alpha updaters
                             case ALLEGRO_KEY_2:
                             {
                                updater_.addAlphaUpdater(
                                   sprite_, 1.0, 2.0,
                                   interpolatorMaker!"t^2]");
                                break;
                             }

                             case ALLEGRO_KEY_W:
                             {
                                updater_.addAlphaUpdater(
                                   sprite_, 0.66, 2.0,
                                   interpolatorMaker!"[circle");
                                break;
                             }

                             case ALLEGRO_KEY_S:
                             {
                                updater_.addAlphaUpdater(
                                   sprite_, 0.33, 2.0,
                                   interpolatorMaker!"t^5]");
                                break;
                             }

                             case ALLEGRO_KEY_X:
                             {
                                updater_.addAlphaUpdater(
                                   sprite_, 0.0, 2.0,
                                   interpolatorMaker!"[exp]");
                                break;
                             }

                             // Color updaters
                             case ALLEGRO_KEY_3:
                             {
                                immutable color =
                                   al_map_rgba_f(1.0, 1.0, 1.0, 1.0);

                                updater_.addColorUpdater(
                                   sprite_, color, 2.0,
                                   interpolatorMaker!"[t^3");
                                break;
                             }

                             case ALLEGRO_KEY_E:
                             {
                                immutable color =
                                   al_map_rgba_f(1.0, 0.0, 0.0, 0.1);

                                updater_.addColorUpdater(
                                   sprite_, color, 2.0,
                                   interpolatorMaker!"sin]");
                                break;
                             }

                             case ALLEGRO_KEY_D:
                             {
                                immutable color =
                                   al_map_rgba_f(0.2, 0.2, 1.0, 1.0);

                                updater_.addColorUpdater(
                                   sprite_, color, 2.0,
                                   interpolatorMaker!"[t^4]");
                                break;
                             }

                             case ALLEGRO_KEY_C:
                             {
                                immutable color =
                                   al_map_rgba_f(0.1, 0.9, 0.3, 0.9);

                                updater_.addColorUpdater(
                                   sprite_, color, 2.0,
                                   interpolatorMaker!"[exp");
                                break;
                             }

                             // Scale updaters
                             case ALLEGRO_KEY_4:
                             {
                                updater_.addScaleUpdater(
                                   sprite_, 1.0, 1.0, 2.0,
                                   interpolatorMaker!"bounce]");
                                break;
                             }

                             case ALLEGRO_KEY_R:
                             {
                                updater_.addScaleUpdater(
                                   sprite_, 0.5, 0.5, 2.0,
                                   interpolatorMaker!"[t^3]");
                                break;
                             }

                             case ALLEGRO_KEY_F:
                             {
                                updater_.addScaleUpdater(
                                   sprite_, 1.7, -0.8, 2.0,
                                   interpolatorMaker!"[t^4");
                                break;
                             }

                             case ALLEGRO_KEY_V:
                             {
                                updater_.addScaleUpdater(
                                   sprite_, 1.8, 1.8, 2.0,
                                   interpolatorMaker!"[back");
                                break;
                             }

                             // Rotation updaters
                             case ALLEGRO_KEY_5:
                             {
                                updater_.addRotationUpdater(
                                   sprite_, 0.0, 2.0,
                                   interpolatorMaker!"[back]");
                                break;
                             }

                             case ALLEGRO_KEY_T:
                             {
                                updater_.addRotationUpdater(
                                   sprite_, PI, 2.0,
                                   interpolatorMaker!"[elastic]");
                                break;
                             }

                             case ALLEGRO_KEY_G:
                             {
                                updater_.addRotationUpdater(
                                   sprite_, -PI, 2.0,
                                   interpolatorMaker!"[circle]");
                                break;
                             }

                             case ALLEGRO_KEY_B:
                             {
                                updater_.addRotationUpdater(
                                   sprite_, 5*PI, 2.0,
                                   interpolatorMaker!"sin]");
                                break;
                             }

                             // Default
                             default:
                                break; // do nothing
                          }
                       });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb_f(0.1, 0.1, 0.1));
      sprite_.draw();
   }

   private AllegroBitmap bitmap_;
   private Sprite sprite_;
   private Updater updater_;
}

void main()
{
   scope crank = new fewdee.engine.Crank();
   fewdee.engine.run(new TheState());
}
