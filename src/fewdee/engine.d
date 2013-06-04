/**
 * The engine core. Provides some very fundamental services, plus some
 * utilities.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.engine;

import allegro5.allegro;
import fewdee.internal.singleton;
import fewdee.allegro_manager;
import fewdee.event_manager;
import fewdee.game_state;
import fewdee.state_manager;
import fewdee.display_manager;
import fewdee.resource_manager;


/**
 * A handy way to start the engine. "Crank", "handy", "start an engine"... witty
 * naming, uh? (Incidentally, FewDee's Crank also stops the engine.)
 *
 * Notice that this is a $(D scope class), so it must be instantiated with the
 * $(D scope) keyword.
 *
 * See_also: https://en.wikipedia.org/wiki/Crank_%28mechanism%29#20th_Century
 */
public scope class Crank
{
   /**
    * Creates the $D(Crank), which causes the engine to be started ($(D
    * fewdee.core.Core.start()) is called).
    */
   public this()
   {
      Engine.start();
   }

   /**
    * Destroys the $D(Crank), which causes the engine to be stopped
    * ($D(fewdee.core.Core.stop()) is called).
    */
   public ~this()
   {
      Engine.stop();
   }
}


/**
 * The real implementation of the Engine. Users shall use this through the $(D
 * Engine) class.
 */
private class EngineImpl
{
   /**
    * Starts the engine. This sets everything up so that the engine can be used,
    * and must be called before any other Engine method.
    *
    * That said, you should use a tool to start the engine: a $(D Crank) (crude,
    * but effective).
    */
   private void start()
   {
      // TODO: Shouldn't all be done here.
      AllegroManager.initSystem();
      AllegroManager.initImageIO();
      AllegroManager.initFont();
      AllegroManager.initTTF();
      AllegroManager.initPrimitives();
      AllegroManager.initMouse();
      AllegroManager.initKeyboard();
      AllegroManager.initJoystick();
      AllegroManager.initAudio();
      AllegroManager.initAudioCodecs();

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
    * shuts down gracefully. You cannot call any other Engine after calling this
    * function.
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
      DisplayManager.destroyInstance();
      ResourceManager.destroyInstance();
      AllegroManager.destroyInstance();
   }

   /**
    * Runs the engine main loop, with a given starting state.
    * TODO: Implement different main loop strategies, with or without the State
    *       Manager.
    */
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

   /**
    * The one and only display.
    * TODO: This is temporary; we should use the Display Manager.
    */
   public ALLEGRO_DISPLAY* TheDisplay;

   /**
    * The object managing the game states.
    * TODO: This is temporary; we should use the State Manager singleton.
    */
   private StateManager TheStateManager;
}



/**
 * The Engine singleton. Provides access to the one and only $(D EngineImpl)
 * instance.
 */
public class Engine
{
   mixin LowLockSingleton!EngineImpl;
}
