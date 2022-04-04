package res.bios.html5;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;

class FrameBuffer extends res.display.FrameBuffer {
	var _imageData:ImageData;
	var _canvas:CanvasElement;
	var _ctx:CanvasRenderingContext2D;

	override public function beginFrame() {}

	override public function clear(index:Int) {
		final color = _palette.get(index);
		for (n in 0...(width * height)) {
			_imageData.data[n * 4] = color.r;
			_imageData.data[n * 4 + 1] = color.g;
			_imageData.data[n * 4 + 2] = color.b;
			_imageData.data[n * 4 + 3] = 255;
		}
	}

	override public function endFrame() {
		_ctx.putImageData(_imageData, 0, 0);
	}

	public function new(canvas, width, height, palette) {
		super(width, height, palette);

		_imageData = new ImageData(width, height);
		_canvas = canvas;
		_ctx = _canvas.getContext2d();
	}

	function setPixel(x:Int, y:Int, color:Color32) {
		final pos = y * width + x;

		_imageData.data[pos * 4] = color.r;
		_imageData.data[pos * 4 + 1] = color.g;
		_imageData.data[pos * 4 + 2] = color.b;
		_imageData.data[pos * 4 + 3] = 255;
	}
}
