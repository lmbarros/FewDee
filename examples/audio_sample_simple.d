/**
 * FewDee's "Simple Audio Sample" example.
 *
 * This example simply plays an audio sample. It has no display at all.
 *
 * Authors: Leandro Motta Barros
 */

import core.thread;
import std.stdio;
import fewdee.all;


// This example shows the simplest way to play an audio sample. Audio samples
// are fully loaded into memory, so they are intended to be used with shorter
// pieces of sound. If you want to play some longer sounds (like music), you'll
// probably want to use audio streams, which load the sound data on demand.

void main()
{
   // Start the engine.
   scope crank = new Crank();

   // Playing an audio sample in FewDee involves two entities. Here, we create
   // the first one, which is an audio sample ('AudioSample'). It contains the
   // audio data, but it is not playable by itself.
   auto audioSample = new AudioSample("data/yes.ogg");

   // The second entity is the audio sample instance ('AudioSampleInstance'). An
   // audio sample instance contains the information necessary to actually play
   // the sound data stored in an 'AudioSample'. Audio sample instances must be
   // instantiated via some methods of 'AudioSample'.
   //
   // Here, we use the 'AudioSample.play()' method to create an audio sample
   // instance that will start playing immediately. The 'AudioSampleInstance'
   // returned by 'play()' will be automatically destroyed by the 'AudioManager'
   // some time after it is paused (and it gets paused automatically when it
   // finishes playing, so you don't have to worry about managing its memory).
   //
   // Notice that, if we simply wanted to play the sound without accessing any
   // of the services provided by 'AudioSampleInstance', we wouldn't even need
   // to store the 'AudioSampleInstance' returned by 'play()'. In this case,
   // we'll need to access one of its properties, so we store it.
   //
   // And a final note: the same 'AudioSample' can be used to create as many
   // 'AudioSampleInstance's as you wish (or as many as the hardware can
   // support, at least). So, you can have a single 'AudioSample' containing
   // audio data for, say, an explosion, and have several 'AudioSampleInstance's
   // playing that sound simultaneously.
   AudioSampleInstance audioSampleInstance = audioSample.play();

   // At this point, the sound is playing. But we need to wait until the sound
   // finishes playing (otherwise the program would exit just after the sound
   // started playing). Therefore, we simply busy wait until the 'isPlaying'
   // property of the audio sample instance becomes 'false' (indicating that it
   // finished playing).
   while (audioSampleInstance.isPlaying)
      continue;

   // Since we did not use the 'ResourceManager' to manage the audio sample, we
   // have to manually free it.
   audioSample.free();
}
