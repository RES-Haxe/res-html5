package res.bios.html5;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;

class CRT extends res.display.CRT {
	var _imageData:ImageData;
	var _canvas:CanvasElement;
	var _ctx:CanvasRenderingContext2D;

	var _width:Int;
	var _height:Int;

	public function new(width:Int, height:Int, canvas:CanvasElement) {
		super([R, G, B, A]);
		_width = width;
		_height = height;

		_imageData = new ImageData(width, height);
		_canvas = canvas;
		_ctx = _canvas.getContext2d();
	}

	public function beam(x:Int, y:Int, index:Int, palette:Palette) {
		if (index == 0)
			return;

		final pos = y * _width + x;

		final color = palette.get(index);

		_imageData.data[pos * 4] = color.r;
		_imageData.data[pos * 4 + 1] = color.g;
		_imageData.data[pos * 4 + 2] = color.b;
		_imageData.data[pos * 4 + 3] = 255;
	}

	override function vblank() {
		_ctx.putImageData(_imageData, 0, 0);
	}
}
