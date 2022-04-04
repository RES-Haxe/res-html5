package res.bios.html5;

import js.html.audio.AudioContext;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;

class AudioBuffer implements IAudioBuffer {
	public final numChannel:Int;
	public final numSamples:Int;
	public final sampleRate:Int;
	public final buffer:js.html.audio.AudioBuffer;

	public function new(ctx:AudioContext, audioStream:IAudioStream) {
		numChannel = audioStream.numChannels;
		sampleRate = audioStream.sampleRate;
		numSamples = audioStream.numSamples;

		buffer = ctx.createBuffer(audioStream.numChannels, audioStream.numSamples, audioStream.sampleRate);

		for (n => sample in audioStream) {
			for (nChannel => amplitude in sample) {
				final channelData = buffer.getChannelData(nChannel);
				channelData[n] = amplitude;
			}
		}
	}
}
