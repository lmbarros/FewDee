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
import fewdee.audio_manager;
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
      // Initialize the Allegro system
      AllegroManager.initSystem();

      // Store the requested features
      _requestedFeatures = features;

      // Initialize bitmap creation flags
      _newBitmapPixelFormat =
         ALLEGRO_PIXEL_FORMAT.ALLEGRO_PIXEL_FORMAT_ANY_WITH_ALPHA;
      _newBitmapFlags =
         ALLEGRO_VIDEO_BITMAP
         | ALLEGRO_MIN_LINEAR
         | ALLEGRO_MAG_LINEAR
         | ALLEGRO_MIPMAP;
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
      EventManager.destroyInstance();
      StateManager.destroyInstance();
      ResourceManager.destroyInstance();
      AudioManager.destroyInstance();
      DisplayManager.destroyInstance();
      AllegroManager.destroyInstance();
   }

   /**
    * Allows to use $(D run()) instead of $(D
    * runWithFixedTickRateAndMaximumDrawRate()).
    *
    * This is less explicit, but a lot shorter and easier to remember. This,
    * with the default parameters of $(D
    * runWithFixedTickRateAndMaximumDrawRate()), may be a good "default" game
    * loop, which should work well enough in common situations.
    *
    * If you care about the details of your main loop (and you probably should
    * for any serious stuff), you probably want to be explicit about which type
    * of main loop you are using. But if you are just experimenting, call $(D
    * run()) and be happy.
    */
   public alias runWithVariableDrawAndTickRates run;

   /**
    * A function used to handle the cases in which the system running the code
    * is not fast enough to keep the requested update rate.
    *
    * This is typically used to humiliate the user, telling him that his
    * computer is not fast enough to run your program (you probably want to say
    * that more politely...) or to make something that will make your program
    * less resource-hungry (perhaps disabling some eye candy).
    *
    * The first parameter passed, $(D tickTime), is time, in seconds, that it
    * actually took to process the last tick or draw cycle. You can compare this
    * with the expected time (e.g., $(D 1.0/requestedFPS)) to find out by how
    * much the program is falling behind the desired speed. (You may chose to
    * act only if the difference is larger than a certain threshold.)
    *
    * The second parameter passed, $(totalTime), is the time, in seconds,
    * elapsed since some arbitrary (but fixed) epoch. You can use this to check
    * how much time has elapsed since the last time the handler was called. This
    * lets you take action only every $(I n) seconds, instead of using even more
    * cycles every time it is called (and it can be called $(I very) frequently,
    * like once per frame).
    */
   public alias void delegate(double tickTime, double totalTime)
      RunningBehindHandler;

   /**
    * Runs a "FPS dependent on Constant Game Speed" main loop while a certain
    * condition is $(D true).
    *
    * This is probably a bad choice of main loop, because of they way that
    * "vsync" influences it (see details below).
    *
    * Both the tick and the draw events will be generated at the same, constant
    * rate. Even if the hardware is not fast enough to keep the requested speed,
    * the event handlers will be told that the requested rate is being
    * used. This behavior is intentional: users of this loop implementation can
    * expect a constant update rate no matter what happens.
    *
    * For every frame that takes more time to process than the time available
    * (that is, more than $(D 1.0/desiredFPS)), the $(D runningBehindHandler())
    * will be called (if one is provided).
    *
    * One final and important note: if "vsync" (AKA "sync to VBlank") is
    * enabled, this loop will not behave correctly. Vsync will cause the display
    * update frequency to limit the rate by which draw (and tick) events are
    * generated. One example: suppose you request a frame rate of 90 FPS, but
    * your monitor is running at 60 FPS. In this case, your loop will never run
    * at the requested frame rate (because you are limited to the monitor's 60
    * FPS, which is less than the required 90 FPS). It will be as if the loop
    * were running behind -- and, indeed, if a "running behind handler" is
    * provided, it will be called every frame, and the game will actually run
    * slower than expected.
    *
    * Parameters:
    *    condition = A delegate returning a Boolean value. While it returns $(D
    *       true), the loop will keep looping.
    *    desiredFPS = The desired frame rate (and tick rate, since they are the
    *       same in this loop implementation).
    *    runningBehindHandler = A delegate that gets called whenever the
    *       processing of a frame takes time than what was available.
    *
    * See_also: http://www.koonsolo.com/news/dewitters-gameloop/
    */
   public final void runWithConstantDrawAndTickRates(
      bool delegate() condition, float desiredFPS = 30.0,
      RunningBehindHandler runningBehindHandler = null)
   {
      immutable tickInterval = 1.0 / desiredFPS;
      auto nextTick = al_get_time();

      while (condition())
      {
         auto now = al_get_time();

         // Generate tick and draw events
         EventManager.triggerTickEvent(tickInterval);
         EventManager.triggerDrawEvent(tickInterval);

         nextTick += tickInterval;

         auto sleepTime = nextTick - now;

         if (sleepTime >= 0.0)
         {
            al_rest(sleepTime);
         }
         else if (runningBehindHandler !is null)
         {
            nextTick = now + tickInterval;
            runningBehindHandler(tickInterval - sleepTime, now);
         }
      }
   }

   /**
    * Runs a "FPS dependent on Constant Game Speed" main loop, with a given
    * starting state. This will loop until $(D StateManager)'s stack of states
    * gets empty.
    *
    * Other than that, this is the same as the other overload of $(D
    * runWithConstantDrawAndTickRates()); please look there for more details.
    */
   public final void runWithConstantDrawAndTickRates(
      GameState startingState, float desiredFPS = 30.0,
      RunningBehindHandler runningBehindHandler = null)
   {
      StateManager.pushState(startingState);
      runWithConstantDrawAndTickRates(
         () => !StateManager.empty, desiredFPS, runningBehindHandler);
   }

   /**
    * Runs a "Game Speed dependent on Variable FPS" main loop while a certain
    * condition is $(D true).
    *
    * Tick and draw events will be generated as fast as possible, but the "delta
    * times" between frames and ticks will float as the workload varies.
    *
    * Also note that "as fast as possible" may not be strictly correct. If
    * "vsync" (AKA "sync to VBlank") is enabled, the update rate will be limited
    * by the display update frequency.
    *
    * Parameters:
    *    condition = A delegate returning a Boolean value. While it returns $(D
    *       true), the loop will keep looping.
    *
    * See_also: http://www.koonsolo.com/news/dewitters-gameloop/
    */
   public final void runWithVariableDrawAndTickRates(bool delegate() condition)
   {
      auto prevTime = al_get_time();

      while (condition())
      {
         // What time is it?
         immutable now = al_get_time();
         immutable deltaT = now - prevTime;
         prevTime = now;

         // Generate tick and draw events
         EventManager.triggerTickEvent(deltaT);
         EventManager.triggerDrawEvent(deltaT);
      }
   }

   /**
    * Runs a "Game Speed dependent on Variable FPS" main loop, with a given
    * starting state. This will loop until $(D StateManager)'s stack of states
    * gets empty.
    *
    * Other than that, this is the same as the other overload of $(D
    * runWithVariableDrawAndTickRates()); please look there for more details.
    */
   public final void runWithVariableDrawAndTickRates(GameState startingState)
   {
      StateManager.pushState(startingState);
      runWithVariableDrawAndTickRates(() => !StateManager.empty);
   }

   /**
    * Runs a "Constant Game Speed with Maximum FPS" or "Constant Game Speed
    * independent of Variable FPS" main loop while a certain condition is $(D
    * true).
    *
    * This will generate tick events at a fixed rate ($(D desiredTPS)), but will
    * generate "draw" events as frequently as possible. If the system is running
    * too slow and cannot keep the requested rate of ticks, up to $(D
    * maxFrameSkip) frames will be skipped. As frames are skipped, $(D
    * runningBehindHandler()) is called if it is provided.
    *
    * In a naïve usage, even when the frame rate is technically greater than the
    * "tick rate", the real frame rate will be limited by the "tick rate": since
    * the game state is updated only in response to tick events, multiple
    * drawings between ticks will end up rendering the same frame multiple
    * times.
    *
    * One mitigation for this is using interpolation to predict the state of
    * objects between system updates. Given that we know the tick rate, and the
    * draw handler receives as parameter the time elapsed since the last draw,
    * we can know how much time elapsed since the last tick event. And the time
    * elapsed since the last tick is the key for state prediction.
    *
    * The code below gives an idea of how to do that.
    *
    * ---
    *
    * const tickTime = 1.0 / desiredTPS;
    *
    * void drawHandler(in ref ALLEGRO_EVENT event)
    * {
    *    static auto acc = 0.0;
    *    acc += event.user.deltaTime;
    *    auto interpolation = 0.0;
    *    if (acc > tickTime)
    *    {
    *       interpolation = 0.0;
    *       acc = 0.0;
    *    }
    *    else
    *    {
    *       interpolation = acc / tickTime;
    *    }
    *
    *    // ... draw using the 'interpolation' value
    * }
    * ---
    *
    * Parameters:
    *    condition = A delegate returning a Boolean value. While it returns $(D
    *       true), the loop will keep looping.
    *    desiredTPS = The desired "tick rate".
    *    maxFrameSkip = The maximum number of consecutive frames that will be
    *       skipped when the system is not fast enough to keep the desired "tick
    *       rate".
    *    runningBehindHandler = A delegate that gets called whenever frames are
    *       skipped.
    *
    * See_also: http://www.koonsolo.com/news/dewitters-gameloop/
    */
   public final void runWithFixedTickRateAndMaximumDrawRate(
      bool delegate() condition, float desiredTPS = 60.0, int maxFrameSkip = 5,
      RunningBehindHandler runningBehindHandler = null)
   {
      immutable tickInterval = 1.0 / desiredTPS;
      auto nextTick = al_get_time();
      auto prevDrawTime = nextTick;

      while (condition())
      {
         auto loops = 0;
         while (al_get_time() >= nextTick && loops <= maxFrameSkip)
         {
            EventManager.triggerTickEvent(tickInterval);

            immutable now = al_get_time();
            auto actualTickTime = tickInterval + now - nextTick;
            nextTick += tickInterval;

            if (loops > 0 && runningBehindHandler !is null)
            {
               runningBehindHandler(actualTickTime, now);
               nextTick = now + tickInterval;
            }

            ++loops;
         }

         immutable now = al_get_time();
         EventManager.triggerDrawEvent(now - prevDrawTime);
         prevDrawTime = now;
      }
   }

   /**
    * Runs a "Constant Game Speed with Maximum FPS" or "Constant Game Speed
    * independent of Variable FPS" main loop, with a given starting state. This
    * will loop until $(D StateManager)'s stack of states gets empty.
    *
    * Other than that, this is the same as the other overload of $(D
    * runWithFixedTickRateAndMaximumDrawRate()); please look there for more
    * details.
    */
   public final void runWithFixedTickRateAndMaximumDrawRate(
      GameState startingState, float desiredTPS = 60.0, int maxFrameSkip = 5,
      RunningBehindHandler runningBehindHandler = null)
   {
      StateManager.pushState(startingState);
      runWithFixedTickRateAndMaximumDrawRate(
         () => !StateManager.empty, desiredTPS, maxFrameSkip,
         runningBehindHandler);
   }

   /**
    * Returns the engine features requested by the user when initializing the
    * Engine.
    */
   package final @property Features requestedFeatures() const
   {
      return _requestedFeatures;
   }

   /// Returns the pixel format that will be used when creating bitmaps.
   public final @property ALLEGRO_PIXEL_FORMAT newBitmapPixelFormat() const
   {
      return _newBitmapPixelFormat;
   }

   /// Sets the pixel format that will be used when creating bitmaps.
   public final @property
   void newBitmapPixelFormat(ALLEGRO_PIXEL_FORMAT pixelFormat)
   {
      _newBitmapPixelFormat = pixelFormat;
   }

   /// Returns the flags that will be used use when creating bitmaps.
   public final @property int newBitmapFlags() const
   {
      return _newBitmapFlags;
   }

   /// Sets the flags that will be used use when creating bitmaps.
   public final @property void newBitmapFlags(int flags)
   {
      _newBitmapFlags = flags;
   }

   /**
    * Do the Allegro calls that effectively set the global (thread-local) flags
    * for bitmap creation. Users shouldn't have many reasons to call this
    * themselves.
    *
    * This gets called for every $(D Bitmap) created. I am assuming that this
    * will not be critical in terms of performance (bitmap creation itself
    * should dominate), but I may be wrong (I did no benchmarks).
    */
   public final void applyBitmapCreationFlags()
   {
      al_set_new_bitmap_format(_newBitmapPixelFormat);
      al_set_new_bitmap_flags(_newBitmapFlags);
   }

   /// The requested engine features.
   private Features _requestedFeatures;

   /// The pixel format to use when creating bitmaps.
   private ALLEGRO_PIXEL_FORMAT _newBitmapPixelFormat;

   /// The flags to use when creating bitmaps.
   private int _newBitmapFlags;
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
