/**
 * A simple example showing the use of AbstractedInput.
 *
 * Authors: Leandro Motta Barros
 */

import std.exception;
import std.stdio;
import fewdee.all;


enum TheCommands
{
   JUMP,
   FIRE,
   NOTHING,
}

class TheState: GameState
{
   this()
   {
      font_ = AllegroFont("data/bluehigl.ttf", 30);
      enforce(font_ !is null);

      // Create the AbstractedInput and add it to the list of event handlers
      // (which are simply objects that get events forwarded to them).
      abstractedInput_ = new AbstractedInput!TheCommands();
      enforce(abstractedInput_ !is null);
      addEventHandler(abstractedInput_);

      // Setup the AbstractedInput
      abstractedInput_.addMapping(keyPress(ALLEGRO_KEY_SPACE), TheCommands.JUMP);
      abstractedInput_.addMapping(keyPress(ALLEGRO_KEY_ALT), TheCommands.FIRE);
      abstractedInput_.addMapping(joyButtonPress(0), TheCommands.JUMP);
      abstractedInput_.addMapping(joyButtonPress(1), TheCommands.FIRE);

      abstractedInput_.addCallback(TheCommands.JUMP, &DoJump);
      abstractedInput_.addCallback(TheCommands.FIRE, &DoFire);

      // This is just to ensure that we can add a callback for which there is no
      // associated mapping.
      abstractedInput_.addCallback(TheCommands.NOTHING, &DoNothing);

      // Quit if ESC is pressed
      addEventCallback(ALLEGRO_EVENT_KEY_DOWN,
                       delegate(in ref ALLEGRO_EVENT event)
                       {
                          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                             popState();
                       });
   }

   public override void onDraw()
   {
      al_clear_to_color(al_map_rgb(50, 50, 50));
      drawText("AbstractedInput simple example", 30, 30);
      drawText("Generate some events and watch the console", 50, 60);
      drawText("Press ESC to quit", 50, 90);
   }

   protected void drawText(string text, float x, float y)
   {
      al_draw_text(font_, al_map_rgb(255, 255, 255), x, y, ALLEGRO_ALIGN_LEFT,
                   text.ptr);
   }

   void DoJump(in ref HighLevelCommandCallbackParam param)
   {
      writeln("JUMP!", param.sourceIsKeyboard ? " (keyboard)" : "");
   }

   void DoFire(in ref HighLevelCommandCallbackParam param)
   {
      writeln("FIRE!", param.sourceIsKeyboard ? " (keyboard)" : "");
   }

   void DoNothing(in ref HighLevelCommandCallbackParam param)
   {
      writeln("NOTHING!");
   }

   protected AllegroFont font_;

   private AbstractedInput!TheCommands abstractedInput_;
}

void main()
{
   scope crank = new fewdee.engine.Crank();
   fewdee.engine.run(new TheState());
}
