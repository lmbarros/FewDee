/**
 * FewDee's Allegro Manager.
 *
 * The Allegro Manager manages which Allegro subsystems have been loaded, and
 * provides means to load them. It also unloads them when the time comes.
 *
 * FewDee users should rarely use this class directly. In fact, the only
 * situation in which end users should use the Allegro Manager is when they want
 * to manually use the Allegro API to do something. For example, suppose you
 * want to have audio in your program, but for some reason you decided to use
 * Allegro's low-level routines instead of FewDee's $(D AudioManager). In this
 * case, in order to ensure that the proper Allegro submodules are loaded (and
 * unloaded, when the program ends). Manually initializing Allegro submodules
 * (by calling $(D al_install_audio()), for example) should be avoided, because
 * FewDee may have initialized the submodule already.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.allegro_manager;

import std.exception;
import allegro5.allegro;
import allegro5.allegro_acodec;
import allegro5.allegro_audio;
import allegro5.allegro_font;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import allegro5.allegro_ttf;
import fewdee.internal.singleton;



/**
 * The real implementation of the Allegro Manager. Users shall use this through
 * the $(D AllegroManager) class.
 *
 * All $(D init*()) methods handle dependencies. For instance, calling $(D
 * AllegroManager.initAudioCodecs()) ensures that the Allegro system and the
 * Allegro audio subsystem are also loaded.
 */
private class AllegroManagerImpl
{
   /**
    * Destroys the Allegro Manager, which, in turn, unloads all loaded Allegro
    * subsystems.
    */
   package ~this()
   {
      // Unload support for file formats
      if (_isImageIOInitialized)
         al_shutdown_image_addon();

      version(none) // This is coming with Allegro 5.1. Leave disabled for now
      {
         if (_isAudioCodecsInitialized)
            al_shutdown_acodec_addon();
      }

      if (_isTTFInitialized)
         al_shutdown_ttf_addon();

      // Unload subsystems
      if (_isJoystickInitialized)
         al_uninstall_joystick();

      if (_isKeyboardInitialized)
         al_uninstall_keyboard();

      if (_isMouseInitialized)
         al_uninstall_mouse();

      version(none) // This is coming with Allegro 5.1. Leave disabled for now
      {
         if (_isTouchInitialized)
            al_uninstall_touch_input();
      }

      if (_isAudioInitialized)
         al_uninstall_audio();

      if (_isFontInitialized)
         al_shutdown_font_addon();

      version(none) // This is likely yo be necessary with Allegro 5.1
      {
         if (_isNativeDialogsInitialized)
            al_shutdown_native_dialog_addon();
      }

      if (_isPrimitivesInitialized)
         al_shutdown_primitives_addon();

      // Unload the Allegro system
      if (_isSystemInitialized)
         al_uninstall_system();
   }

   /// Loads the Allegro System, if it is not already loaded.
   public final void initSystem()
   {
      if (!_isSystemInitialized)
      {
         enforce(al_init(), "Error initializing the Allegro system");
         _isSystemInitialized = true;
      }
   }

   /// Is the Allegro System loaded?
   private bool _isSystemInitialized = false;

   /// Loads the Allegro joystick subsystem, if not already loaded.
   public final void initJoystick()
   {
      if (!_isJoystickInitialized)
      {
         initSystem();
         enforce(al_install_joystick(),
                 "Error initializing the image I/O subsystem");
         _isJoystickInitialized = true;
      }
   }

   /// Is the joystick subsystem loaded?
   private bool _isJoystickInitialized = false;

   /// Loads the Allegro keyboard subsystem, if not already loaded.
   public final void initKeyboard()
   {
      if (!_isKeyboardInitialized)
      {
         initSystem();
         enforce(al_install_keyboard(),
                 "Error initializing the keyboard subsystem");
         _isKeyboardInitialized = true;
      }
   }

   /// Is the keyboard subsystem loaded?
   private bool _isKeyboardInitialized = false;

   /// Loads the Allegro mouse subsystem, if not already loaded.
   public final void initMouse()
   {
      if (!_isMouseInitialized)
      {
         initSystem();
         enforce(al_install_mouse(), "Error initializing the mouse subsystem");
         _isMouseInitialized = true;
      }
   }

   // Is the mouse subsystem loaded?
   private bool _isMouseInitialized = false;

   version(none) // This is coming with Allegro 5.1. Leave disabled for now
   {
      /// Loads the Allegro touch input subsystem, if not already loaded.
      public final void initTouch()
      {
         if (!_isTouchInitialized)
         {
            initSystem();
            enforce(al_install_touch_input(),
                    "Error initializing the touch input subsystem");
            _isTouchInitialized = true;
         }
      }

      /// Is the touch input subsystem loaded?
      private bool _isTouchInitialized = false;
   } // version (none)

   /// Loads the Allegro audio subsystem, if not already loaded.
   public final void initAudio()
   {
      if (!_isAudioInitialized)
      {
         version(linux)
         {
            // TODO: Under Linux, PulseAudio is used by default, but doesn't
            //       work for me (nor for other people around the
            //       Internet). Here, we are simply forcing the use of ALSA; a
            //       less authoritarian approach would be nice.
            al_set_config_value(
               al_get_system_config(), "audio", "driver", "alsa");
         }

         initSystem();
         enforce(al_install_audio(), "Error initializing the audio subsystem");
         _isAudioInitialized = true;
      }
   }

   /// Is the audio subsystem loaded?
   private bool _isAudioInitialized = false;

   /// Loads the Allegro audio codecs subsystem, if not already loaded.
   public final void initAudioCodecs()
   {
      if (!_isAudioCodecsInitialized)
      {
         initSystem();
         initAudio();
         enforce(al_init_acodec_addon(),
                 "Error initializing the audio codecs subsystem");
         _isAudioCodecsInitialized = true;
      }
   }

   /// Is the audio codecs subsystem loaded?
   private bool _isAudioCodecsInitialized = false;


   /**
    * Loads the Allegro font subsystem, if not already loaded. Notice that for
    * actually loading fonts from files, either the TTF or the Image I/O
    * subsystems must be also initialized (depending on the desired font
    * format).
    */
   public final void initFont()
   {
      if (!_isFontInitialized)
      {
         initSystem();

         version(none) // For Allegro 5.1
         {
            enforce(al_init_font_addon(),
                    "Error initializing the font subsystem");
         }
         else
         {
            al_init_font_addon();
         }

         _isFontInitialized = true;
      }
   }

   /// Is the font subsystem loaded?
   private bool _isFontInitialized = false;

   /// Loads the Allegro TTF subsystem, if not already loaded.
   public final void initTTF()
   {
      if (!_isTTFInitialized)
      {
         initSystem();
         initFont();
         enforce(al_init_ttf_addon(), "Error initializing the TTF subsystem");
         _isTTFInitialized = true;
      }
   }

   /// Is the TTF subsystem loaded?
   private bool _isTTFInitialized = false;

   /// Loads the Allegro image I/O subsystem, if not already loaded.
   public final void initImageIO()
   {
      if (!_isImageIOInitialized)
      {
         initSystem();
         enforce(al_init_image_addon(),
                 "Error initializing the image I/O subsystem");
         _isImageIOInitialized = true;
      }
   }

   /// Is the image I/O subsystem loaded?
   private bool _isImageIOInitialized = false;

   version(none) // This is likely yo be necessary with Allegro 5.1
   {
      /// Loads the Allegro native dialogs subsystem, if not already loaded.
      public final void initNativeDialogs()
      {
         if (!_isNativeDialogsInitialized)
         {
            initSystem();
            enforce(al_init_native_dialog_addon(),
                    "Error initializing the native dialogs subsystem");
            _isNativeDialogsInitialized = true;
         }
      }

      /// Is the native dialogs subsystem loaded?
      private bool _isNativeDialogsInitialized = false;
   }

   /// Loads the Allegro primitives subsystem, if not already loaded.
   public final void initPrimitives()
   {
      if (!_isPrimitivesInitialized)
      {
         initSystem();
         enforce(al_init_primitives_addon(),
                 "Error initializing the primitives subsystem");
         _isPrimitivesInitialized = true;
      }
   }

   /// Is the primitives subsystem loaded?
   private bool _isPrimitivesInitialized = false;
}



/**
 * The Allegro Manager singleton. Provides access to the one and only $(D
 * AllegroManagerImpl) instance.
 */
public class AllegroManager
{
   mixin LowLockSingleton!AllegroManagerImpl;
}
