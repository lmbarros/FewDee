/**
 * A low(ish)-level Audio Stream resource.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.audio_stream;

import std.exception;
import std.string;
import allegro5.allegro_audio;
import fewdee.allegro_manager;
import fewdee.audio_manager;
import fewdee.low_level_resource;


/**
 * A low(ish)-level audio stream resource; encapsulates an $(D
 * ALLEGRO_AUDIO_STREAM*) and manages the necessary interactions with the $(D
 * AudioManager).
 *
 * Unlike $(D AudioSample)s, $(D AudioStreams) don't need a separate "instance"
 * object. The same object manages the audio data and the playing state.
 */
public class AudioStream: LowLevelResource
{
   /**
    * Creates an $(D AudioStream), reading its contents from a given file.
    *
    * The $(D AudioStream) is created in a paused state. Call $(D play()) to
    * send it through the speakers.
    *
    * Parameters:
    *    path = The path to the bitmap image file.
    *    bufferCount = The number of buffers to use when reading data from this
    *       stream.
    *    numSamples = The number of samples in each buffer.
    */
   this(in string path, uint bufferCount = 4, uint numSamples = 2048)
   {
      AllegroManager.initAudioCodecs();
      _stream = al_load_audio_stream(path.toStringz, bufferCount, numSamples);

      enforce(_stream !is null,
              "Couldn't load audio stream from '" ~ path ~ "'");

      al_set_audio_stream_playing(_stream, false);
      al_set_audio_stream_playmode(
         _stream, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE);

      AudioManager.addAudioStream(_stream);
   }

   /// Frees all resources used by the $(D AudioStream).
   public void free()
   {
      AudioManager.removeAudioStream(_stream);
      al_destroy_audio_stream(_stream);
      _stream = null;
   }

   /// Starts (or resumes) playing the audio stream.
   public final void play()
   {
      al_set_audio_stream_playing(_stream, true);
   }

   /// Pauses the audio stream, keeping the playing position.
   public final void pause()
   {
      al_set_audio_stream_playing(_stream, false);
   }

   /// Stops the audio stream; rewinds the stream.
   public final void stop()
   {
      al_drain_audio_stream(_stream);
      al_rewind_audio_stream(_stream);
   }

   /// Checks if the audio stream is playing.
   public final @property bool isPlaying()
   {
      return al_get_audio_stream_playing(_stream);
   }

   /**
    * The playback mode (play once, loop...) for this $(D AudioStream).
    *
    * For reference, here are the possible values as of Allegro 5.0.7: $(D
    * ALLEGRO_PLAYMODE_ONCE), $(D ALLEGRO_PLAYMODE_LOOP) and $(D
    * ALLEGRO_PLAYMODE_BIDIR).
    */
   public final @property ALLEGRO_PLAYMODE playMode()
   {
      return al_get_audio_stream_playmode(_stream);
   }

   /// Ditto
   public final @property void playMode(ALLEGRO_PLAYMODE playMode)
   {
      al_set_audio_stream_playmode(_stream, playMode);
   }

   /**
    * The audio stream playing position, in seconds.
    *
    * This assumes a relative playing speed of $(D 1.0).
    */
   public final @property float position()
   {
      return al_get_audio_stream_position_secs(_stream);
   }

   /// Ditto
   public final @property void position(float position)
   {
      al_seek_audio_stream_secs(_stream, position);
   }

   /**
    * The audio stream length, in seconds.
    *
    * This assumes a relative playing speed of $(D 1.0).
    */
   public final @property float length()
   {
      return al_get_audio_stream_length_secs(_stream);
   }

   /**
    * The audio stream relative playing speed.
    *
    * The default value is $(D 1.0). $(D 2.0) means playing twice as fast, $(D
    * 0.5) means playing at half speed, and so on.
    */
   public final @property float speed()
   {
      return al_get_audio_stream_speed(_stream);
   }

   /// Ditto
   public final @property void speed(float speed)
   {
      // Allegro docs don't mention it, but changing the stream speed while
      // connected to the mixer didn't work for me.
      AudioManager.removeAudioStream(_stream);
      al_set_audio_stream_speed(_stream, speed);
      AudioManager.addAudioStream(_stream);
   }

   /**
    * The audio stream amplification factor.
    *
    * The default value is $(D 1.0). $(D 2.0) means playing twice as loud, $(D
    * 0.5) means playing at half the normal volume, and so on.
    */
   public final @property float gain()
   {
      return al_get_audio_stream_gain(_stream);
   }

   /// Ditto
   public final @property void gain(float gain)
   {
      al_set_audio_stream_gain(_stream, gain);
   }

   /**
    * The audio balance (this is what Allegro calls "pan").
    *
    * A value of $(D 0.0) (the default) centers the sound on both speakers; $(D
    * -1.0) plays the sound only through the left speaker; $(D +1.0) plays it
    * only through the right speaker; and intermediate values produce the
    * expected intermediate behavior.
    */
   public final @property float balance()
   {
      return al_get_audio_stream_pan(_stream);
   }

   /// Ditto
   public final @property void balance(float balance)
   {
      al_set_audio_stream_pan(_stream, balance);
   }

   /**
    * The wrapped $(D ALLEGRO_AUDIO_STREAM*). This is public just to make the
    * $(D alias this) work.
    */
   public ALLEGRO_AUDIO_STREAM* _stream;

   // Let this be used with the Allegro functions.
   alias _stream this;
}
