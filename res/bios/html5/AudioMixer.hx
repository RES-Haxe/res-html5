package res.bios.html5;

import js.html.audio.AudioContext;
import res.audio.IAudioBuffer;

class AudioMixer extends res.audio.AudioMixer {
	final _ctx:AudioContext;

	public function new(ctx:AudioContext) {
		_ctx = ctx;
	}

	public function createAudioChannel(buffer:IAudioBuffer, loop:Bool):res.audio.AudioChannel
		return new AudioChannel(_ctx, cast buffer, loop);
}
