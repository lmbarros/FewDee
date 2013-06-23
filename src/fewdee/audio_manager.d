/**
 * FewDee's Audio Manager and related definitions.
 *
 * The Audio Manager allows to play audio samples and audio streams. And stop
 * them. And seek. And loop. These things.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.audio_manager;

import std.exception;
import allegro5.allegro_audio;
import fewdee.allegro_manager;
import fewdee.resource_manager;
import fewdee.llr.audio_sample;
import fewdee.internal.singleton;


/**
 * An instance of an audio sample.
 *
 * Just like in Allegro, audio samples in FewDee have two parts: the sample
 * data, represented by an $(D AudioSample) object, and a small set of
 * information like the playing status, playback position and playback speed,
 * which are represented by this structure.
 *
 * It is safe to call $(D AudioSampleInstance)'s methods even for an instance
 * that already had its $(D destroy()) method called (either manually or
 * automatically). Those calls will be no-ops.
 *
 * FewDee users don't create $(D AudioSampleInstance) instances
 * directly. Instead, they mus call either $(D AudioManager.play()) or $(D
 * AudioManager.createAudioSampleInstance()).
 */
struct AudioSampleInstance
{
   @disable this();

   /**
    * Constructs the $(D AudioSampleInstance).
    *
    * Parameters:
    *    asiKey = The audio sample instance key within $(D AudioManager._asis)
    *       and $(D AudioManager._asisAutoDestroy).
    */
   private this(size_t asiKey)
   {
      _asiKey = asiKey;
   }

   /**
    * Manually frees the resources associated with this $(D
    * AudioSampleInstance).
    *
    * Depending on how an $(D AudioSampleInstance) was created, it may be
    * automatically destroyed, in which case you don't have to manually call
    * this method. Anyway, it is safe to call this method, if you wish to force
    * destruction at some given moment. It is safe to call any method after the
    * object is destroyed -- in this case, the calls will be no-ops (and this
    * includes this method itself: it is OK to destroy an audio sample instance
    * multiple times).
    */
   public final void destroy()
   {
      AudioManager.asiDestroy(_asiKey);
   }

   /// Starts (or resumes) playing the audio sample instance.
   public final void play()
   {
      AudioManager.asiSetPlaying(_asiKey, true);
   }

   /**
    * Pauses the audio sample instance.
    *
    * Notice that pausing an audio sample instance that was created by $(D
    * AudioManager.play()) is not a good idea, since this makes the instance
    * eligible for auto destruction.
    */
   public final void pause()
   {
      AudioManager.asiSetPlaying(_asiKey, false);
   }

   /**
    * Sets the playback mode (play once, loop...) for this $(D
    * AudioSampleInstance).
    *
    * Parameters:
    *    playMode = The desired playback mode. For easier reference, here are
    *       the possible values as of Allegro 5.0.7: $(D ALLEGRO_PLAYMODE_ONCE),
    *       $(D ALLEGRO_PLAYMODE_LOOP) and $(D ALLEGRO_PLAYMODE_BIDIR).
    */
   public final @property void playMode(ALLEGRO_PLAYMODE playMode)
   {
      AudioManager.asiSetPlaymode(_asiKey, playMode);
   }

   /**
    * Gets the length of the audio sample instance, in seconds, assuming a
    * playing speed of $(D 1.0).
    */
   public final @property float length()
   {
      return AudioManager.asiGetLength(_asiKey);
   }

   /// The playing position, in seconds, assuming a playing speed of $(D 1.0).
   public final @property float position()
   {
      return AudioManager.asiGetPosition(_asiKey);
   }

   /// Ditto
   public final @property position(float position)
   {
      return AudioManager.asiSetPosition(_asiKey, position);
   }

   /**
    * The relative playing speed.
    *
    * The default is $(D 1.0). If the speed is $(D 2.0), the sound will be
    * played twice as fast. If the speed is $(D 0.5), the sound will be played
    * at half of its normal speed. And I guess that from here you can infer how
    * this works.
    */
   public final @property void speed(float speed)
   {
      AudioManager.asiSetSpeed(_asiKey, speed);
   }

   /// Ditto
   public final @property float speed()
   {
      return AudioManager.asiGetSpeed(_asiKey);
   }

   /// Checks whether this $(D AudioSampleInstance) is currently playing.
   public final @property bool isPlaying()
   {
      return AudioManager.asiIsPlaying(_asiKey);
   }

   /**
    * The amplification factor used to play this audio sample instance.
    *
    * The default is $(D 1.0). Larger values make the sound louder, smaller
    * values make the sound softer.
    */
   public final @property void gain(float gain)
   {
      AudioManager.asiSetGain(_asiKey, gain);
   }

   /// Ditto
   public final @property float gain()
   {
      return AudioManager.asiGetGain(_asiKey);
   }

   /**
    * The audio balance (this is what Allegro calls "pan").
    *
    * A value of ($D 0.0) (the default) centers the sound on both speakers; $(D
    * -1.0) plays the sound only through the left speaker; $(D +1.0) plays it
    * only through the right speaker; and intermediate values produce the
    * expected intermediate behavior.
    */
   public final @property void balance(float balance)
   {
      AudioManager.asiSetBalance(_asiKey, balance);
   }

   /// Ditto
   public final @property float balance()
   {
      return AudioManager.asiGetBalance(_asiKey);
   }

   /**
    * The audio sample instance key within $(D AudioManager._asis) and $(D
    * AudioManager._asisAutoDestroy).
    */
   private size_t _asiKey = AudioManagerImpl._invalidASIKey;
}



/**
 * The real implementation of the Audio Manager. Users shall use this through
 * the $(D AudioManager) class.
 */
private class AudioManagerImpl
{
   /**
    * Constructs the Audio Manager.
    *
    * TODO:
    *    There is a big deal of hardcoded things here (audio depth, mixer
    *    frequency...) Those should be made user-definable. Via engine
    *    initialization parameters, perhaps.
    */
   private this()
   {
      // Initialize Allegro's audio subsystem
      AllegroManager.initAudio();
      AllegroManager.initAudioCodecs();

      // Initialize the voice
      _voice = al_create_voice(
         44100,
         ALLEGRO_AUDIO_DEPTH.ALLEGRO_AUDIO_DEPTH_INT16,
         ALLEGRO_CHANNEL_CONF.ALLEGRO_CHANNEL_CONF_2);
      enforce(_voice, "Error initializing the audio device.");
      scope(failure)
         al_destroy_voice(_voice);

      // Initialize the mixer
      _mixer = al_create_mixer(
         44100,
         ALLEGRO_AUDIO_DEPTH.ALLEGRO_AUDIO_DEPTH_FLOAT32,
         ALLEGRO_CHANNEL_CONF.ALLEGRO_CHANNEL_CONF_2);

      enforce(_mixer, "Error initializing the audio mixer.");
      scope(failure)
         al_destroy_mixer(_mixer);

      // Sets the audio connections
      al_attach_mixer_to_voice(_mixer, _voice);
   }

   /// Destroys the $(D AudioManager).
   package ~this()
   {
      foreach(asi; _asis)
         al_destroy_sample_instance(asi);

      al_destroy_mixer(_mixer);
      al_destroy_voice(_voice);
   }

   //
   // The public interface
   //

   /**
    * Plays an audio sample, using audio data from a given $(D AudioSample).
    *
    * This method is the most "fire-and-forget" way to play a sound sample. It
    * will play the sound and automatically manage the necessary resources. If
    * you simply call this method using the default play mode (play once) and
    * ignore its return value, you'll not do anything wrong.
    *
    * But this method offers a little bit of extra flexibility, which you can
    * leverage if you pay attention to one little detail: the $(D
    * AudioSampleInstance) returned by this method will be managed by the $(D
    * AudioManager), but the $(D AudioManager) doesn't know how to check if the
    * sound finished playing. So, it will assume that it can destroy the
    * resources associated with the sample instance when and only when it
    * notices that the sound is paused.
    *
    * This brings two consequences:
    *
    * $(OL
    *    $(LI If you manually call $(D pause()), you are effectively saying "I
    *       am done with this audio sample instance; please, $(D AudioManager),
    *       destroy it when you find it appropriate.")
    *    $(LI If you play the sound in a playing mode that loops forever, the
    *       audio sample instance resources will not be freed (after all, it
    *       never pause). In this case, you are expected to $(D pause()) when
    *       you don't want it anymore. (You can also explicitly $(D destroy())
    *       it, but pausing it is enough to guarantee its eventual destruction
    *       by the $(D AudioManager))).
    * )
    *
    * If you need to able to pause and resume the returned $(D
    * AudioSampleInstance), use $(D createAudioSampleInstance()) instead.
    *
    * Parameters:
    *    sample = The audio sample to be played. Not $(D null), please.
    *    playMode = The desired play mode.
    *
    * Returns:
    *    An $(D AudioSampleInstance) that can be used to control the playing
    *    parameters. (But read this method's full documentation for some
    *    warnings about using it.)
    */
   public final AudioSampleInstance play(
      AudioSample sample,
      ALLEGRO_PLAYMODE playMode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE)
   in
   {
      assert(sample !is null);
   }
   body
   {
      auto asi = createAudioSampleInstance(sample, true);
      asi.playMode = playMode;
      asi.play();

      return asi;
   }

   /**
    * Convenience overload that takes the audio sample data from the $(D
    * ResourceManager).
    *
    * This is just like the overload taking a $(D AudioSampleInstance) as
    * parameter, but it takes a string instead. This string is used as the key
    * to retrieve the audio sample data from the $(D ResourceManager).
    *
    * All details, caveats and warnings mentioned in the documentation of the
    * other overload also apply here, so take a look there.
    */
   public final AudioSampleInstance play(
      string key,
      ALLEGRO_PLAYMODE playMode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE)
   {
      auto sample = ResourceManager.samples[key];

      enforce(sample !is null, "Audio sample '" ~ key ~ "' not found");

      return play(sample);
   }

   /**
    * Creates and returns an audio sample instance from a given $(D
    * AudioSample).
    *
    * You are responsible for destroying the returned $(D AudioSampleInstance),
    * by calling its $(D destroy()) method.
    *
    * Parameters:
    *    sample = The audio sample data to use. No $(D null)s here, please.
    *
    * Returns:
    *    A newly constructed $(D AudioSampleInstance). You are responsible for
    *    destroying it.
    */
   public final AudioSampleInstance
   createAudioSampleInstance(AudioSample sample)
   in
   {
      assert(sample !is null);
   }
   body
   {
      return createAudioSampleInstance(sample, false);
   }

   /**
    * Convenience overload that creates and returns an audio sample instance
    * from an audio sample in the $(ResourceManager).
    *
    * This is just like the overload taking a $(D AudioSampleInstance) as
    * parameter, but it takes a string instead. This string is used as the key
    * to retrieve the audio sample data from the $(D ResourceManager).
    *
    * All details, caveats and warnings mentioned in the documentation of the
    * other overload also apply here, so take a look there.
    */
   public final AudioSampleInstance createAudioSampleInstance(string key)
   {
      auto sample = ResourceManager.samples[key];
      enforce(sample, "Audio sample '" ~ key ~ "' not found");
      return createAudioSampleInstance(sample);
   }

   /**
    * Destroys the audio sample instances that are marked as "auto destroy" $(I
    * and) have finished playing.
    *
    * Well, actually we cannot really detected if the audio sample instance
    * really finished playing. The implementation assumes that a paused sample
    * instance is finished.
    *
    * FewDee users shouldn't have to call this manually, but the function is
    * public just in case someone wants to ensure that the resources associated
    * with the finished audio sample instances are freed at a given point of
    * their program.
    */
   public final void destroyFinishedAudioSampleInstances()
   {
      size_t[] toRemove = [ ];
      foreach (key, asi; _asis)
      {
         if (_asisAutoDestroy[key] && al_get_sample_instance_playing(asi))
            toRemove ~= key;
      }

      foreach(key; toRemove)
      {
         _asis[key].destroy();
         _asis.remove(key);
         _asisAutoDestroy.remove(key);
      }
   }

   //
   // Private helper methods
   //

   /**
    * Creates and returns an audio sample instance.
    *
    * This $(D private) overload is for internal use only (naturally).
    *
    * Parameters:
    *    sample = The audio sample data to use. No $(D null)s here, please.
    *    autoDestroy = Shall the created audio sample instance be automatically
    *       destroyed by the $(D AudioManager) when it finishes playing? Notice
    *       that if you pass $(D true) here, you are supposed to start playing
    *       the audio sample instance immediately (as part of the same function
    *       that called this one), otherwise the audio sample instance may be
    *       auto destroyed before the user had a chance to use it.
    *
    * Returns:
    *    A newly constructed $(D AudioSampleInstance).
    */
   private final AudioSampleInstance
   createAudioSampleInstance(AudioSample sample, bool autoDestroy)
   in
   {
      assert(sample !is null);
   }
   body
   {
      destroyFinishedAudioSampleInstances();

      auto asi = al_create_sample_instance(sample);
      enforce(asi !is null, "Error creating audio sample instance");

      auto key = _nextASIKey++;
      _asis[key] = asi;
      _asisAutoDestroy[key] = autoDestroy;

      al_attach_sample_instance_to_mixer(asi, _mixer);

      return AudioSampleInstance(key);
   }

   //
   // Methods that do the real work of AudioSampleInstance ("ASI") methods
   //

   /// Destroys the "ASI" whose key passed as parameter.
   private final void asiDestroy(size_t asiKey)
   {
      if (asiKey in _asisAutoDestroy && _asisAutoDestroy[asiKey])
      {
         assert(asiKey in _asis); // _asis and _asisAutoDestroy must be in sync

         al_destroy_sample_instance(_asis[asiKey]);
         _asis.remove(asiKey);
         _asisAutoDestroy.remove(asiKey);
      }
   }

   /// Gets the "is playing" state of the "ASI" whose key passed as parameter.
   private final bool asiIsPlaying(size_t asiKey)
   {
      if (asiKey !in _asis)
         return false;

      return al_get_sample_instance_playing(_asis[asiKey]);
   }

   /// Sets the "is playing" state of the "ASI" whose key passed as parameter.
   private final void asiSetPlaying(size_t asiKey, bool play)
   {
      if (asiKey in _asis)
         al_set_sample_instance_playing(_asis[asiKey], play);
   }

   /// Gets the length (in seconds) of the "ASI" whose key passed as parameter.
   private final float asiGetLength(size_t asiKey)
   {
      if (asiKey !in _asis)
         return 0;

      const asi = _asis[asiKey];

      return al_get_sample_instance_length(asi)
         / cast(float)(al_get_sample_instance_frequency(asi));
   }

   /**
    * Gets the playing position (in seconds) of the "ASI" whose key passed as
    * parameter.
    */
   private final float asiGetPosition(size_t asiKey)
   {
      if (asiKey !in _asis)
         return 0.0;

      const asi = _asis[asiKey];

      return al_get_sample_instance_position(_asis[asiKey])
         / cast(float)(al_get_sample_instance_frequency(asi));
   }

   /**
    * Sets the playing position (in seconds) of the "ASI" whose key passed as
    * parameter.
    */
   private final void asiSetPosition(size_t asiKey, float position)
   {
      if (asiKey in _asis)
      {
         auto asi = _asis[asiKey];
         al_set_sample_instance_position(
            asi, cast(uint)(position * al_get_sample_instance_frequency(asi)));
      }
   }

   /**
    * Gets the relative playing speed of the "ASI" whose key passed as
    * parameter.
    */
   private final float asiGetSpeed(size_t asiKey)
   {
      if (asiKey !in _asis)
         return 0;
      return al_get_sample_instance_speed(_asis[asiKey]);
   }

   /**
    * Sets the relative playing speed of the "ASI" whose key passed as
    * parameter.
    */
   private final void asiSetSpeed(size_t asiKey, float speed)
   {
      if (asiKey in _asis)
         al_set_sample_instance_speed(_asis[asiKey], speed);
   }

   /// Sets the playing mode of the "ASI" whose key passed as parameter.
   private final void asiSetPlaymode(size_t asiKey, ALLEGRO_PLAYMODE playMode)
   {
      if (asiKey in _asis)
         al_set_sample_instance_playmode(_asis[asiKey], playMode);
   }

   /// Gets the gain of the "ASI" whose key passed as parameter.
   private final float asiGetGain(size_t asiKey)
   {
      if (asiKey !in _asis)
         return 0;
      return al_get_sample_instance_gain(_asis[asiKey]);
   }

   /// Sets the gain of the "ASI" whose key passed as parameter.
   private final void asiSetGain(size_t asiKey, float gain)
   {
      if (asiKey in _asis)
         al_set_sample_instance_gain(_asis[asiKey], gain);
   }

   /// Gets the balance ("pan") of the "ASI" whose key passed as parameter.
   private final float asiGetBalance(size_t asiKey)
   {
      if (asiKey !in _asis)
         return 0;
      return al_get_sample_instance_pan(_asis[asiKey]);
   }

   /// Sets the balance ("pan") of the "ASI" whose key passed as parameter.
   private final void asiSetBalance(size_t asiKey, float balance)
   {
      if (asiKey in _asis)
         al_set_sample_instance_pan(_asis[asiKey], balance);
   }

   /// The one and only Allegro voice (an audio device).
   private ALLEGRO_VOICE* _voice;

   /// The one and only Allegro mixer (which, well, mixes sounds).
   private ALLEGRO_MIXER* _mixer;

   /**
    * An audio sample instance ("ASI") key that is guaranteed to be different
    * than all valid ASIs.
    */
   private static immutable size_t _invalidASIKey = 0;

   /**
    * The value to use as the key for the next audio sample instance ("ASI")
    * created.
    */
   private size_t _nextASIKey = _invalidASIKey + 1;

   /**
    * Maps audio sample instance ("ASI") keys to the Allegro object representing
    * the ASI itself.
    */
   private ALLEGRO_SAMPLE_INSTANCE*[size_t] _asis;

   /**
    * Maps audio sample instance ("ASI") keys to the flags determining whether
    * the corresponding ASI must be automatically destroyed by the $(D
    * AudioManager) or not.
    */
   private bool[size_t] _asisAutoDestroy;
}



/**
 * The Audio Manager singleton. Provides access to the one and only $(D
 * AudioManagerImpl) instance.
 */
public class AudioManager
{
   mixin LowLockSingleton!AudioManagerImpl;
}
