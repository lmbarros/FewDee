/**
 * A low-level Audio Stream resource.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.llr.audio_stream;

import std.exception;
import std.string;
import allegro5.allegro_audio;
import fewdee.llr.low_level_resource;


/**
 * A low-level bitmap resource. Encapsulates an $(D ALLEGRO_AUDIO_STREAM*).
 */
class AudioStream: LowLevelResource
{
   /**
    * Creates an AudioStream, reading its contents from a given file.
    *
    * Parameters:
    *    path = The path to the bitmap image file.
    *    bufferCount = The number of buffers to use when reading data from this
    *       stream.
    *    numSamples = The number of samples in each buffer.
    */
   this(in string path, uint bufferCount = 4, uint numSamples = 2048)
   {
      _stream = al_load_audio_stream(path.toStringz, bufferCount, numSamples);
      enforce(_stream !is null);
   }

   /// Frees all resources used by the AudioStream.
   public void free()
   {
      al_destroy_audio_stream(_stream);
      _stream = null;
   }

   /**
    * The wrapped $(D ALLEGRO_AUDIO_STREAM*). This is public just to make the
    * $(D alias this) work.
    */
   public ALLEGRO_AUDIO_STREAM* _stream;

   // Let this be used with the Allegro functions.
   alias _stream this;
}
