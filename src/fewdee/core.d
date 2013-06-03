/**
 * The engine core. Provides some very fundamental services, plus some
 * utilities.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.core;

import allegro5.allegro;
import allegro5.allegro_audio;  // TODO: remove from core?
import allegro5.allegro_acodec; // TODO: remove form core?
import allegro5.allegro_font;
import allegro5.allegro_ttf;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import fewdee.internal.singleton;
import fewdee.event;
import fewdee.event_manager;
import fewdee.game_state;
import fewdee.ref_counted_wrappers;
import fewdee.state_manager;
import fewdee.display_manager;
import fewdee.resource_manager;


/**
 * A handy way to start the engine. Crank, handy, start an engine... witty
 * naming, uh? (Incidentally, FewDee's Crank also stops the engine.)
 *
 * Notice that this is a $(D scope class), so it must be instantiated with the
 * $(D scope) keyword.
 *
 * See_also: https://en.wikipedia.org/wiki/Crank_%28mechanism%29#20th_Century
 */
public scope class Crank
{
      import std.stdio;

   /**
    * Creates the $D(Crank), which causes the engine to be started ($(D
    * fewdee.core.Core.start()) is called).
    */
   public this()
   {
      Core.start();
   }

   /**
    * Destroys the $D(Crank), which causes the engine to be stopped
    * ($D(fewdee.core.Core.stop()) is called).
    */
   public ~this()
   {
      Core.stop();
   }
}


// TODO: review docs! Er, and everything else!
private class CoreImpl
{
   /**
    * Starts the core. This sets everything up so that the engine can be used,
    * and must be called before any other $(D fewdee.engine) function.
    *
    * That said, you should use a tool to start the engine: $(D Crank) (crude,
    * but effective).
    */
   private void start()
   {
      // A "macro" for initializing something with the proper error checking,
      // recovery and reporting.
      string makeInitCode(string initCode, string cleanupCode, string errMsg)
      {
         return "if (!" ~ initCode ~ ")
                    throw new Exception(\"" ~ errMsg ~ "\");
                 scope (failure) " ~ cleanupCode ~ ";";
      }

      mixin (makeInitCode("al_init()", "al_uninstall_system()",
                          "Initialization failed miserably"));

      mixin (makeInitCode("al_init_image_addon()", "al_shutdown_image_addon()",
                          "Error initializing image subsystem"));

      mixin (makeInitCode("(al_init_font_addon(), true)",
                          "al_shutdown_font_addon()",
                          "Error initializing font subsystem"));

      mixin (makeInitCode("al_init_ttf_addon()", "al_shutdown_ttf_addon()",
                          "Error initializing font subsystem"));

      mixin (makeInitCode("al_init_primitives_addon()",
                          "al_shutdown_primitives_addon()",
                          "Error initializing font subsystem"));

      mixin (makeInitCode("al_install_mouse()", "al_uninstall_mouse()",
                          "Error initializing mouse"));

      mixin (makeInitCode("al_install_keyboard()", "al_uninstall_keyboard()",
                          "Error initializing keyboard"));

      mixin (makeInitCode("al_install_joystick()", "al_uninstall_joystick()",
                          "Error initializing joystick"));

      // TODO: These probably shouldn't be in the core. But how to ensure that
      //       the audio subsystem is initialized in the moment we create, say,
      //       an AudioSample object?
      mixin (makeInitCode("al_install_audio()", "al_uninstall_audio()",
                          "Error initializing audio"));

      if (!al_init_acodec_addon())
         throw new Exception("Error initializing audio codecs");

      // Don't use pre-multiplied alpha by default
      al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD,
                     ALLEGRO_BLEND_MODE.ALLEGRO_ALPHA,
                     ALLEGRO_BLEND_MODE.ALLEGRO_INVERSE_ALPHA);

      al_set_new_bitmap_flags(ALLEGRO_NO_PREMULTIPLIED_ALPHA
                              | ALLEGRO_MIN_LINEAR
                              | ALLEGRO_MAG_LINEAR);
   }

   /**
    * Stops the engine. This sets shuts everything down so that your program
    * shuts down gracefully. You cannot call any other $(D fewdee.engine) after
    * calling this function.
    *
    * BTW, you should use a $(D Crank) to start and stop the engine -- this is
    * $(D private), you cannot even call this manually.
    *
    * See_also: Crank
    */
   private void stop()
   {
      // TODO: calling destroyInstance() in an uninstantiated singleton is OK;
      //       but must think well about the ordering of destruction.
      EventManager.destroyInstance();

      al_uninstall_joystick();

      al_uninstall_keyboard();

      al_uninstall_mouse();

      DisplayManager.destroyInstance();
      ResourceManager.destroyInstance();

      al_uninstall_audio(); // TODO: This one probably shouldn't be in the core.

      al_shutdown_primitives_addon();

      al_shutdown_ttf_addon();

      al_shutdown_font_addon();

      al_shutdown_image_addon();

      al_uninstall_system();
   }

   /// Runs the engine main loop, with a given starting state.
   void run(GameState startingState)
   {
      TheStateManager.pushState(startingState);

      double prevTime = al_get_time();

      while (!TheStateManager.empty)
      {
         // What time is it?
         immutable now = al_get_time();
         immutable deltaT = now - prevTime;
         prevTime = now;

         // Generate tick event
         EventManager.triggerTickEvent(deltaT);

         // Draw!
         EventManager.triggerDrawEvent(deltaT);
      }
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public ALLEGRO_DISPLAY* TheDisplay;

   /// The object managing the game states.
   private StateManager TheStateManager;
}



/**
 * The Core singleton. Provides access to the one and only $(D
 * CoreImpl) instance.
 */
public class Core
{
   mixin LowLockSingleton!CoreImpl;
}
