/**
 * FewDee's Display Manager and related definitions.
 *
 * The Display Manager allows to create, destroy, modify and configure Displays
 * (which are the places where things are drawn, like a window or "a full
 * screen").
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.display_manager;

import std.exception;
import allegro5.allegro;
import fewdee.engine;
import fewdee.event_manager;
import fewdee.internal.singleton;


/**
 * Information describing one monitor attached to the system. If you need to
 * obtain information about the available monitors, use $(D
 * DisplayManager.monitors).
 *
 * See_also: DisplayManager.monitors.
 */
public struct MonitorInfo
{
   /**
    * Constructs a $(D MonitorInfo) from the corresponding Allegro struct. This
    * constructor is for internal usage only.
    *
    * Parameters:
    *    mi = The Allegro structure constaining the monitor information.
    */
   private this(ALLEGRO_MONITOR_INFO mi)
   {
      _x1 = mi.x1;
      _y1 = mi.y1;
      _x2 = mi.x2;
      _y2 = mi.y2;
   }

   /**
    * Returns the monitor's left edge. The main monitor's left edge is at 0; the
    * other monitors' $(D left)s are relative to the main one.
    */
   public @property int left() const { return _x1; }

   /**
    * Returns the monitor's top edge. The main monitor's top edge is at 0; the
    * other monitors' $(D top)s are relative to the main one.
    */
   public @property int top() const { return _y1; }

   /// Returns the monitor's width, in pixels.
   public @property int width() const { return _x2 - _x1; }

   /// Returns the monitor's height, in pixels.
   public @property int height() const { return _y2 - _y1; }

   /// The monitor's left edge.
   private int _x1;

   /// The monitor's top edge.
   private int _y1;

   /// The monitor's right edge.
   private int _x2;

   /// The monitor's bottom edge.
   private int _y2;
}



/**
 * Parameters describing a Display; used when creating a new one. The defaults
 * should be reasonable for casual FewDee usage.
 */
public struct DisplayParams
{
   /// Shall the Display be a full screen? (Otherwise, it is a window.)
   public bool fullScreen = true;

   /**
    * Shall the desktop resolution be used as the display resolution? If not,
    * the display size will come from $(D width) and $(D height).
    */
   public bool useDesktopResolution = true;

   /**
    * The Display width, in pixels. Ignored if $(D useDesktopResolution ==
    * true).
    */
   public uint width = 640;

   /**
    * The Display height, in pixels. Ignored if $(D useDesktopResolution ==
    * true).
    */
   public uint height = 480;

   /// Shall VSync be enabled?
   public bool vSync = true;

   /// Which display adapter to use?
   public int adapter = ALLEGRO_DEFAULT_DISPLAY_ADAPTER;
}



/// A Display, which is either a window or "a full screen".
public class Display
{
   /**
    * Constructs the Display.
    *
    * Parameters:
    *    params = The desired Display characteristics.
    */
   package this(in DisplayParams params)
   {
      _display = al_create_display(params.width, params.height);
      enforce(_display !is null);
   }

   /// Destroys the Display.
   ~this()
   {
      al_unregister_event_source(EventManager.eventQueue,
                                 al_get_display_event_source(_display));
      al_destroy_display(_display);
   }

   /// The Allegro object representing the Display.
   private ALLEGRO_DISPLAY* _display;

   // TODO: As of DMD 2.063, enabling the 'alias this' below causes a crash when
   //       destroying the displays (during program shutdown). I am inclined to
   //       blame the compiler, but I really have no idea why this happens.
   // alias _display this; // Make usable with the Allegro API
}



/**
 * The real implementation of the Display Manager. Users shall use this through
 * the $(D DisplayManager) class.
 */
private class DisplayManagerImpl
{
   /**
    * Destroys the $(D DisplayManager), which, in turn, destroys all $(D
    * Displays).
    */
   package ~this()
   {
      foreach(d; _displays)
         destroy(d);
      _displays = typeof(_displays).init;
   }

   /// Returns an array with information about all the detected monitors.
   public final @property MonitorInfo[] monitors() const
   {
      MonitorInfo[] monitors = [];

      const numMonitors = al_get_num_video_adapters();

      foreach (i; 0..numMonitors)
      {
         ALLEGRO_MONITOR_INFO info;
         const success = al_get_monitor_info(i, &info);
         if (success)
            monitors ~= MonitorInfo(info);
      }

      return monitors;
   }

   /**
    * Returns a list of the supported full screen display modes.
    *
    * TODO:
    *    I don't know how this works when multiple monitors are connected to the
    *    computer. No spare monitor to test this right now, though.
    */
   public final @property
   immutable(ALLEGRO_DISPLAY_MODE[]) fullScreenDisplayModes() const
   {
      ALLEGRO_DISPLAY_MODE[] modes = [ ];

      immutable n = al_get_num_display_modes();
      modes.length = n;

      foreach (i; 0..n)
      {
         ALLEGRO_DISPLAY_MODE mode;
         al_get_display_mode(i, &mode);
         modes[i] = mode;
      }

      return assumeUnique(modes);
   }

   /**
    * Creates a new $(D Display) and puts it under the control of the $(D
    * DisplayManager).
    *
    * If the created display is the only one in the internal list of displays,
    * $(D setTargetDisplay()) is called on the newly created $(D Display),
    * making it the target of subsequent drawing operations.
    *
    * Parameters:
    *    name = The name of the display being created. If a display with this
    *       name already exists, the old display is destroyed and replaced with
    *       the new one.
    *    params = The parameters describing the desired display features.
    *
    * Returns:
    *    For eventual convenience, returns the newly created $(D Display).
    */
   public final Display createDisplay(
      in string name, in DisplayParams params = DisplayParams())
   {
      auto d = new Display(params);
      enforce(d !is null, "Error creating Display");

      al_register_event_source(
         EventManager.eventQueue,
         al_get_display_event_source(d._display));

      if (name in _displays)
         destroy(_displays[name]);

      _displays[name] = d;

      if (_displays.length == 1)
         setTargetDisplay(name);

      return d;
   }

   /**
    * Sets the $(D Display) with a given name as the target for subsequent
    * drawing operations.
    *
    * This is called automatically for a newly created $(D Display) when it is
    * the only display in he internal list of $(D Display)s maintained by the
    * $(D DisplayManager). However, you may wish to call this manually to set a
    * different $(D Display) as the target of drawing operations. Also, calling
    * this method is necessary if you manually set the target bitmap to
    * something different (e.g., by calling Allegro's $(D
    * al_set_target_bitmap()) and then wants to draw to a $(D Display) again.
    */
   public final void setTargetDisplay(in string displayName)
   in
   {
      assert(displayName in _displays);
   }
   body
   {
      al_set_target_backbuffer(_displays[displayName]._display);
   }

   /// The collection of $(D Display)s, indexed by their string keys.
   private Display[string] _displays;
}



/**
 * The Display Manager singleton. Provides access to the one and only $(D
 * DisplayManagerImpl) instance.
 */
public class DisplayManager
{
   mixin LowLockSingleton!DisplayManagerImpl;
}
