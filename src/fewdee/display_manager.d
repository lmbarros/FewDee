/**
 * FewDee's Display Manager and related definitions.
 *
 * The Display Manager allows to create, destroy, modify and configure Displays
 * (which are the places where things are drawn, like a window or "a full
 * screen").
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.display_manager;

import std.exception;
import allegro5.allegro;
import fewdee.core;
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
    *    mi = The Allegro structure describing 
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
struct DisplayParams
{
   /// Shall the Display be a full screen? (Otherwise, it is a window.)
   bool fullScreen = true;

   /**
    * Shall the desktop resolution be used as the display resolution? If not,
    * the display size will come from $(D width) and $(D height).
    */
   bool useDesktopResolution = true;

   /**
    * The Display width, in pixels. Ignored if $(D useDesktopResolution ==
    * true).
    */
   uint width = 640;

   /**
    * The Display height, in pixels. Ignored if $(D useDesktopResolution ==
    * true).
    */
   uint height = 480;

   /// Shall VSync be enabled?
   bool vSync = true;

   /// Which display adapter to use?
   int adapter = ALLEGRO_DEFAULT_DISPLAY_ADAPTER;
}


/// A Display, which is either a window or "a full screen".
class Display
{
   /**
    * Constructs the Display.
    *
    * Parameters:
    *    params = The desired Display characteristics.
    */
   this(in DisplayParams params)
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
}



/**
 * The real implementation of the Display Manager. Users shall use this through
 * the $(D DisplayManager) class.
 */
private class DisplayManagerImpl
{
   /// Constructs the Display Manager.
   private this()
   {
      // Nothing here...
   }

   /// Destroys the DisplayManager, which, in turn, destroys all Displays.
   package ~this()
   {
      foreach(d; _displays)
         destroy(d);
      _displays = typeof(_displays).init;
   }

   // TODO: implement this xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   public @property MonitorInfo[] monitors()
   {
      return [];
      // ...
   }

   public Display createDisplay(
      in string name, in DisplayParams params = DisplayParams())
   {
      auto d = new Display(params);
      enforce(d !is null);

      Core.TheDisplay = d._display; // TODO: hack!
      al_register_event_source(
         EventManager.eventQueue,
         al_get_display_event_source(Core.TheDisplay)); // TODO: hack!

      _displays[name] = d;

      if (_currentDisplay is null)
         _currentDisplay = d;

      return d;
   }

   /// The collection of Displays, indexed by their string keys.
   private Display[string] _displays;

   private Display _currentDisplay;
}



/**
 * The Display Manager singleton. Provides access to the one and only $(D
 * DisplayManagerImpl) instance.
 */
public class DisplayManager
{
   mixin LowLockSingleton!DisplayManagerImpl;
}
