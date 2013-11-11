library renderers;

import 'dart:html';
import 'dart:math';
import '../models/vector.dart';
import '../models/level.dart';

abstract class Renderer {

	bool redraw = true;
	
	render();
	
	resize(int width, int height);
	
	clearCanvas(canvas) {
		CanvasRenderingContext ctx = canvas.getContext('2d');
		ctx.clearRect(0, 0, canvas.width, canvas.height);
	}
	
	bool remove();
	
}

class LevelRenderer extends Renderer {
	Level level;
	
	HtmlElement parent;
	CanvasElement canvas;
	CanvasRenderingContext2D ctx;
	num scalingFactor;

	LevelRenderer(this.parent, this.level) {
		canvas = new CanvasElement(width: 0, height: 0);
		ctx = canvas.getContext('2d');
		parent.append(canvas);
	}

  render() {
		clearCanvas(canvas);
		for (int x = 0; x < level.width; x++) {
			for (int y = 0; y < level.height; y++) {
				Field f = level.fields[x][y];	
				Vector scaledPos = f.pos.scale(scalingFactor);
				String fillColor = 'black', text;
				
				switch (f.type) {
					case FieldType.EMPTY:
						ctx.strokeStyle = 'black';
						ctx.strokeRect(scaledPos.x, scaledPos.y, scalingFactor, scalingFactor);
						fillColor = 'white';
						break; 
					case FieldType.START:
						fillColor = 'lightgrey';
						break;
					case FieldType.GOAL:
						fillColor = 'green';
						break;
				}
				ctx
					..fillStyle = fillColor
					..fillRect(scaledPos.x, scaledPos.y, scalingFactor, scalingFactor);
			}
		}
		redraw = false;
  }

  resize(int width, height) {
		scalingFactor = min(width / level.width, height / level.height);
		
		//TODO: I guess this could be done with CSS
		parent.style
			..width = '${scaledWidth}px'
			..height = '${scaledHeight}px';
		canvas
			..setAttribute('height', "$scaledHeight")
			..setAttribute('width', "$scaledWidth");
		canvas.style.position = 'absolute';
//		canvas.style.left = '${(window.innerWidth - scaledWidth / 2)}px';
//		canvas.style.top = '${(window.innerHeight - scaledHeight / 2)}px';
  }
	
	get scaledWidth => scalingFactor * level.width;
	get scaledHeight => scalingFactor * level.height;
	

  remove() {
    canvas.remove();
		return true;
  }
}

class PathRenderer extends Renderer {

	Iterable<Field> path;
	
	LevelRenderer levelRenderer;
	
	CanvasElement fieldCanvas;
	CanvasElement numberCanvas;
	
	List<CanvasElement> canvases;
	
	PathRenderer(HtmlElement parent, this.levelRenderer, this.path) {
		numberCanvas = levelRenderer.canvas.clone(true);
		fieldCanvas = numberCanvas.clone(true);
		canvases = [fieldCanvas, numberCanvas]
			..forEach((canvas) => parent.append(canvas));
	}

  render() {
		canvases.forEach((canvas) => clearCanvas(canvas));
		
		CanvasRenderingContext2D ctx;
		int i = 0;
		path.forEach((Field f) {
			Vector fieldPos = f.pos.scale(scalingFactor);
			
			// Don't draw over start
			if (i > 0) {
				var start = {'red': 0, 'green': 0, 'blue': 255},
						end = {'red': 255, 'green': 0, 'blue': 0};
				num	percentFade = i / path.length,
						diffRed = start['red'] + percentFade * (end['red'] - start['red']),
						diffGreen = start['green'] + percentFade * (end['green'] - start['green']),
						diffBlue = start['blue'] + percentFade * (end['blue'] - start['blue']);
				
				fieldCanvas.getContext('2d')
					..fillStyle = 'rgb(${diffRed.round()}, ${diffGreen.round()}, ${diffBlue.round()})'
					..fillRect(fieldPos.x, fieldPos.y, scalingFactor, scalingFactor);
			}
		

			ctx = numberCanvas.getContext('2d');
			String text = '$i';
			if (i == 0) text = 'S';
			Vector textPos = fieldPos.plus(
				scalingFactor / 2 - ctx.measureText(text).width / 2,
				scalingFactor / 2 + ctx.measureText('M').width / 2
			);
			ctx
				..font = '${scalingFactor / 2}px Arial'
				..fillText(text, textPos.x, textPos.y);
			
			i++;
		});
  }

  resize(w, h) {
		canvases.forEach((canvas) => canvas.attributes = levelRenderer.canvas.attributes);
  }
	
	remove() {
		canvases.forEach((canvas) => canvas.remove());
		return true;
	}
	
	get scalingFactor => levelRenderer.scalingFactor;

}