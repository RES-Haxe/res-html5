package res.bios.html5;

import js.Browser.document;
import js.Browser.navigator;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Gamepad;
import js.html.KeyboardEvent;
import js.html.PointerEvent;
import js.html.audio.AudioContext;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.input.ControllerButton;

using Math;

enum ControllerMode {
	KEYBOARD;
	GAMEPAD;
}

class BIOS extends res.bios.BIOS {
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var scale:Int;

	var res:RES;

	var lastTime:Float = 0;

	var gamepads:Map<Int, Gamepad> = [];

	var audioContext:AudioContext;

	final gamepadButtons:Map<Int, Map<Int, Bool>> = [];

	final gamepapControllerMap:Array<{ctrl:ControllerButton, gpd:Int}> = [
		{ctrl: A, gpd: 0}, {ctrl: B, gpd: 1}, {ctrl: X, gpd: 2}, {ctrl: Y, gpd: 3}, {ctrl: SELECT, gpd: 8}, {ctrl: START, gpd: 9}, {ctrl: DOWN, gpd: 13},
		{ctrl: LEFT, gpd: 14}, {ctrl: UP, gpd: 12}, {ctrl: RIGTH, gpd: 15},
	];

	final controllerMode:Map<Int, ControllerMode> = [0 => KEYBOARD, 1 => KEYBOARD, 2 => KEYBOARD, 3 => KEYBOARD];

	/**
		@param canvas Canvas element. Will create and add a new one if not set
		@param scale Scale of the image
		@param injectCSS Inject CSS to make the canvas look crisp
	 */
	public function new(?canvas:CanvasElement, ?scale:Int = 4, ?injectCSS:Bool = true) {
		super('HTML5');

		if (canvas == null) {
			canvas = document.createCanvasElement();
			document.body.appendChild(canvas);
		}

		this.scale = scale;

		this.canvas = canvas;

		if (injectCSS) {
			final canvasStyle = document.createStyleElement();
			canvasStyle.type = 'text/css';
			canvasStyle.innerHTML = 'html, body {margin: 0; padding: 0;} canvas { image-rendering: pixelated; image-rendering: crisp-edges; }';

			document.getElementsByTagName('head').item(0).appendChild(canvasStyle);
		}

		this.ctx = this.canvas.getContext2d();

		this.audioContext = new AudioContext();
	}

	inline function gamepadButtonPressed(gpIndex:Int, button:Int):Bool {
		return gamepadButtons[gpIndex].exists(button) && gamepadButtons[gpIndex][button];
	}

	function gamepadButtonDown(gamepad, index:Int, button:Int, ctrlButton:ControllerButton) {
		controllerMode[index] = GAMEPAD;
		res.ctrl(index).keyboardMap = false;
		res.ctrl(index).press(ctrlButton);
	}

	function gamepadButtonUp(gamepad, index:Int, button:Int, ctrlButton:ControllerButton) {
		if (controllerMode[index] == GAMEPAD)
			res.ctrl(index).release(ctrlButton);
	}

	function updateGamepads() {
		for (index => gamepad in navigator.getGamepads()) {
			if (gamepad != null) {
				if (!gamepadButtons.exists(index))
					gamepadButtons.set(index, []);

				for (mp in gamepapControllerMap) {
					if (gamepad.buttons[mp.gpd].pressed && !gamepadButtonPressed(index, mp.gpd)) {
						gamepadButtonDown(gamepad, index, mp.gpd, mp.ctrl);
						gamepadButtons[index][mp.gpd] = true;
					} else if (!gamepad.buttons[mp.gpd].pressed && gamepadButtonPressed(index, mp.gpd)) {
						gamepadButtonUp(gamepad, index, mp.gpd, mp.ctrl);
						gamepadButtons[index][mp.gpd] = false;
					}
				}
			}
		}
	}

	function animationFrame(time:Float) {
		final dt:Float = (time - lastTime) / 1000;

		lastTime = time;

		updateGamepads();

		res.update(dt);
		res.render();

		window.requestAnimationFrame(animationFrame);
	}

	public function connect(res:RES) {
		this.res = res;

		canvas.width = res.width;
		canvas.height = res.height;

		canvas.style.width = '${res.width * scale}px';
		canvas.style.height = '${res.height * scale}px';

		canvas.addEventListener('pointermove', (event:PointerEvent) -> {
			res.mouse.moveTo((event.x / scale).floor(), (event.y / scale).floor());
		});

		canvas.addEventListener('pointerdown', (event:PointerEvent) -> {
			res.mouse.push(switch (event.button) {
				case 0: LEFT;
				case 1: MIDDLE;
				case 2: RIGHT;
				case _: LEFT;
			}, (event.x / scale).floor(), (event.y / scale).floor());
		});

		canvas.addEventListener('pointerup', (event:PointerEvent) -> {
			res.mouse.release(switch (event.button) {
				case 0: LEFT;
				case 1: MIDDLE;
				case 2: RIGHT;
				case _: LEFT;
			}, (event.x / scale).floor(), (event.y / scale).floor());
		});

		window.addEventListener('keydown', (event:KeyboardEvent) -> {
			if (event.key.length == 1)
				res.keyboard.input(event.key);

			final mapping = res.keyboard.whichMap(event.keyCode);

			if (mapping != null)
				res.ctrl(mapping.index).keyboardMap = true;

			res.keyboard.keyDown(event.keyCode);
		});

		window.addEventListener('keyup', (event:KeyboardEvent) -> {
			res.keyboard.keyUp(event.keyCode);
		});

		document.addEventListener('visibilitychange', (event) -> {
			lastTime = window.performance.now();
		});

		window.requestAnimationFrame(animationFrame);
	}

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer
		return new AudioBuffer(audioContext, audioStream);

	public function createAudioMixer():AudioMixer
		return new AudioMixer(audioContext);

	public function createStorage():res.storage.Storage
		return new Storage();

	public function createCRT(width:Int, height:Int):res.CRT
		return new CRT(width, height, canvas);

	public function startup() {}
}
