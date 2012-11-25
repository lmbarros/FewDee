/**
 * A simple example showing the use of Updater.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.stdio;
import fewdee.all;


class TheState: GameState
{
   this()
   {
      font_ = al_load_ttf_font("data/bluehigl.ttf", 30, 0);
      enforce(font_ !is null);

      // Create the updater and add it to the list of event handlers (which are
      // simply objects that get events forwarded to them).
      updater_ = new Updater();
      enforce(updater_ !is null);
      addEventHandler(updater_);

      // Start an updater when the mouse is clicked. Notice that many instances
      // of the updater function will run simultaneously if the user clicks
      // several times in sequence.
      addEventCallback(ALLEGRO_EVENT_MOUSE_BUTTON_UP, &startUpdater);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });
   }

   ~this()
   {
      al_destroy_font(font_);
   }

   // Here we create a closure and add it to the Updater. This will run for one
   // and a half second.
   void startUpdater(in ref ALLEGRO_EVENT event)
   {
      double totalTime = 0.0;
      updater_.add(
         delegate(double deltaTime)
         {
            totalTime += deltaTime;
            writefln("%s: Updater called (%s seconds)", &totalTime, totalTime);
            return totalTime < 1.5;
         });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(50, 50, 50));
      drawText("Updater simple example", 30, 30);
      drawText("Click to start updater", 50, 60);
      drawText("Press ESC to quit", 50, 90);
   }

   protected void drawText(string text, float x, float y)
   {
      al_draw_text(font_, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                   text.ptr);
   }

   protected ALLEGRO_FONT* font_;

   private Updater updater_;
}

void main()
{
   auto engine = Engine(640, 480);
   engine.run(new TheState());
}
