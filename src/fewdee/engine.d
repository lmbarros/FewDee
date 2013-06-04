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


/// A list of features that can be enabled when initializing the engine.
enum Features
{
   /// Enable generation of mouse events.
   MOUSE = 0x00000001,

   /// Enable generation of keyboard events.
   KEYBOARD = 0x00000002,

   /// Enable generation of joystick events.
   JOYSTICK = 0x00000004,

   /// Disable all supported features.
   NONE = 0,

   /// Enable all supported features.
   I_WANT_IT_ALL = MOUSE | KEYBOARD | JOYSTICK
}


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
    *
    * Parameters:
    *    features = The desired engine features. By default, all features are
    *       enabled. If you know that, say keyboard events will not be used in
    *       your program, you can pass $(Features.D I_WANT_IT_ALL &
    *       ~Features.KEYBOARD) here and hope to spare a few microsseconds per
    *       frame.
    */
   public this(Features features = Features.I_WANT_IT_ALL)
   {
      Engine.start(features);
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
    *
    * Parameters:
    *    features = The desired engine features.
    */
   private final void start(Features features)
   {
      // Initialize what we need
      AllegroManager.initSystem();

      // Store the requested features.
      _requestedFeatures = features;

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
   private final void stop()
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
   public final void run(GameState startingState)
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
    * Returns the engine features requested by the user when initializing the
    * Engine.
    */
   package final @property Features requestedFeatures() const
   {
      return _requestedFeatures;
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

   /// The requested engine features.
   private Features _requestedFeatures;
}



/**
 * The Engine singleton. Provides access to the one and only $(D EngineImpl)
 * instance.
 */
public class Engine
{
   mixin LowLockSingleton!EngineImpl;
}


//
// Unit tests
//

// All engine features disabled
unittest
{
   import std.functional;
   import fewdee.event_manager;

   // Start the Engine requesting no features
   scope crank = new Crank(Features.NONE);

   // Initialize the Event Manager, which in turn will initialize all requested
   // input devices (none, in this case).
   auto em = EventManager.instance;

   // Use the Allegro API to ensure that the input subsystems were not
   // initialized.
   assert(!al_is_keyboard_installed());
   assert(!al_is_mouse_installed());
   assert(!al_is_joystick_installed());
}


// All engine features enabled (the default)
unittest
{
   import std.functional;
   import fewdee.event_manager;

   // Start the Engine requesting all features (the default)
   scope crank = new Crank();

   // Initialize the Event Manager, which in turn will initialize all requested
   // input devices (in this case, all of them).
   auto em = EventManager.instance;

   // Use the Allegro API to ensure that the input subsystems were not
   // initialized.
   assert(al_is_keyboard_installed());
   assert(al_is_mouse_installed());
   assert(al_is_joystick_installed());
}
