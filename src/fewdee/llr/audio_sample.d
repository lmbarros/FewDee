/**
 * A low-level Audio Sample resource.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.llr.audio_sample;

import std.exception;
import std.string;
import allegro5.allegro_audio;
import fewdee.llr.low_level_resource;


/**
 * A low-level sound sample resource. Encapsulates an $(D ALLEGRO_SAMPLE*).
 */
class AudioSample: LowLevelResource
{
   /**
    * Creates an AudioSample, reading its contents from a given file.
    *
    * Parameters:
    *    path = The path to the audio file.
    */
   this(in string path)
   {
      _sample = al_load_sample(path.toStringz);
      enforce(_sample !is null);
   }

   /// Frees all resources used by the AudioSample.
   public void free()
   {
      al_destroy_sample(_sample);
      _sample = null;
   }

   /**
    * The wrapped $(D ALLEGRO_SAMPLE*). This is public just to make the $(D
    * alias this) work.
    */
   public ALLEGRO_SAMPLE* _sample;

   // Let this be used with the Allegro functions.
   alias _sample this;
}
