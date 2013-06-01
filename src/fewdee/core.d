/**
 * The engine core. Provides some very fundamental services, plus some
 * utilities.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.core;

import allegro5.allegro;
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


shared static this()
{
   Core.start();
}

shared static ~this()
{
   Core.stop();
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
    * BTW, you should use a $(D Crank) to start and stop the engine, instead of
    * calling this manually.
    *
    * See_also: Crank
    */
   private void stop()
   {
      EventManager.finalize(); // TODO: must check if inited; and think about ordering

      al_uninstall_joystick();

      al_uninstall_keyboard();

      al_uninstall_mouse();

      DisplayManager.finalize(); // TODO: must check if initialized

      if (isResourceManagerInited)
         ResourceManager.finalize();

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

   /**
    * Is the Display Manager initialized? Only the Display Manager itself should
    * set this to $(D true).
    */
   package bool isDisplayManagerInited = false;

   /**
    * Is the Event Manager initialized? Only the Event Manager itself should set
    * this to $(D true).
    */
   package bool isEventManagerInited = false;

   /**
    * Is the Resource Manager initialized? Only the Resource Manager itself
    * should set this to $(D true).
    */
   package bool isResourceManagerInited = false;
}


/**
 * The Core singleton. Provides access to the one and only $(D
 * CoreImpl) instance.
 */
public class Core
{
   mixin LowLockSingleton!CoreImpl;
}
