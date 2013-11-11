import 'models/level.dart';
import 'models/search.dart';
import 'views/renderer.dart';
import 'views/menu.dart';
import 'dart:html';

Level level;

LevelRenderer levelRenderer;
PathRenderer pathRenderer;
List<Renderer> renderers = [];

main() {
	window.onResize.listen((e) => resize());
	HtmlElement	container = document.querySelector('#searchContainer'),
							canvasContainer = container.querySelector('.canvasContainer');
	
	removeRenderer(renderer) {
		renderers.removeWhere((r2) => renderer == r2 && renderer.remove());	
	}
	initLevelRenderer() {
		removeRenderer(levelRenderer);
		removeRenderer(pathRenderer);
		
		levelRenderer = new LevelRenderer(canvasContainer, level); 
		renderers.addAll([levelRenderer]);
		resize();
	}
	
	attachMenuListeners(container, 
		onRandomLevel: (int width, int height) {
			level = new Level.random(width, height);
			initLevelRenderer();
		},
		onLoadLevel: (levelString) {
			level = new Level.fromAsciiString(levelString);
			initLevelRenderer();
		},
		onSearch: (String searchId) {
			Search search;
			switch (searchId) {
				case 'bfs':
					search = new BreadthFirst(level);
					break;
				case 'dfs':
					search = new DepthFirst(level);
					break;
				case 'astar':
					search = new AStar(level);
					break;
			}
			
			removeRenderer(pathRenderer);
			renderers.add(
				(pathRenderer = new PathRenderer(canvasContainer, levelRenderer, search.path)..render())
			);
		},
		onClearSearch: () => removeRenderer(pathRenderer)
	);
}

resize() {
	renderers.forEach((renderer) { 
		renderer
			..resize(window.innerWidth, window.innerHeight - (menuSize + 10))
			..redraw = true;
	});
	render();
}

render() {
	renderers.forEach((renderer) {
		if (renderer.redraw) renderer.render();	
	});
}
