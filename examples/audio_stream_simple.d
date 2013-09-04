/**
 * FewDee's "Simple Audio Stream" example.
 *
 * This example simply plays an audio stream. It has no display at all.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

import core.thread;
import std.stdio;
import fewdee.all;


// This example shows the simplest way to play an audio stream. Audio streams
// load (and unload) data to memory as they are played. It is thus appropriate
// for long sounds (like music). For shorter sounds, you may prefer to use audio
// samples, which are a bit more flexible (for example: you can play the same
// audio sample multiple times simultaneously).

void main()
{
   al_run_allegro(
   {
      // Start the engine.
      scope crank = new Crank();

      // The first step to play an audio stream in FewDee is to create the
      // 'AudioStream' object. This is simple enough.
      auto audioStream = new AudioStream("data/Bassa_Island_Game_Loop.ogg");

      // The second (and final) step is to play it. This is even simpler.
      audioStream.play();

      // At this point, the stream is playing. But we need to wait until it
      // finishes playing (otherwise the program would exit just after the sound
      // started playing). Therefore, we simply busy wait until the 'isPlaying'
      // property of the audio stream becomes 'false' (indicating that it
      // finished playing).
      while (audioStream.isPlaying)
         continue;

      // Since we did not use the 'ResourceManager' to manage the audio stream,
      // we have to manually free it.
      audioStream.free();

      // We're done!
      return 0;
   });
}
