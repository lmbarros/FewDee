/**
 * A low(ish)-level Audio Sample resource.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.audio_sample;

import std.exception;
import std.string;
import allegro5.allegro_audio;
import fewdee.allegro_manager;
import fewdee.audio_manager;
import fewdee.low_level_resource;


/**
 * A low(ish)-level sound sample resource; encapsulates an $(D ALLEGRO_SAMPLE*)
 * and do the necessary interactions with the $(D AudioManager).
 *
 * This is the object that owns audio sample data.
 */
public class AudioSample: LowLevelResource
{
   /**
    * Creates an AudioSample, reading its contents from a given file.
    *
    * Parameters:
    *    path = The path to the audio file.
    */
   this(in string path)
   {
      AllegroManager.initAudioCodecs();
      _sample = al_load_sample(path.toStringz);
      enforce(_sample !is null,
              "Couldn't load audio sample  from '" ~ path ~ "'");
   }

   /// Frees all resources used by the AudioSample.
   public void free()
   {
      al_destroy_sample(_sample);
      _sample = null;
   }

   /**
    * Plays the audio sample once.
    *
    * The resources associated with the returned $(D AudioSampleInstance) will
    * be automatically freed by the $(D AudioManager) some time after the
    * playing is paused (either because it paused automatically after finished
    * playing or because you paused it manually by calling the $(D pause())
    * method).
    *
    * Returns:
    *    An $(D AudioSampleInstance) that can be used to query or tinker with
    *    the playing parameters.
    */
   public final AudioSampleInstance play()
   {
      auto asi = AudioManager.createAudioSampleInstance(_sample, true);
      asi.playMode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE;
      asi.play();

      return asi;
   }

   /**
    * Creates and returns an $(D AudioSampleInstance) using audio sample data
    * from this $(D AudioSample).
    *
    * The caller is responsible for freeing the resources associated with the
    * returned $(D AudioSampleInstance) (by calling its $(D destroy()) method).
    *
    * The returned $(D AudioSampleInstance) is created in the paused state, and
    * with a "play once" playback mode.
    *
    * Returns:
    *    An $(D AudioSampleInstance). The caller is responsible for freeing its
    *    resources by calling its $(D destroy()) method.
    */
   public final AudioSampleInstance createInstance()
   {
      auto asi = AudioManager.createAudioSampleInstance(_sample, false);
      asi.playMode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE;
      asi.pause();

      return asi;
   }

   /**
    * The wrapped $(D ALLEGRO_SAMPLE*). This is public just to make the $(D
    * alias this) work.
    */
   public ALLEGRO_SAMPLE* _sample;

   // Let this be used with the Allegro functions.
   alias _sample this;
}
