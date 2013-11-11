library search;

import 'level.dart';
import 'dart:collection';


abstract class Search {

	bool goalReached = false;
	bool unreachable = false;
	
	Level level;
	
	Queue<Field> frontier;
	
	List<Field> path = [];
	
	Search(this.level) {
		frontier = new Queue.from([level.start]);
		findPath();
	}
	
	bool findPath() {
		while (frontier.isNotEmpty && !goalReached) {
			Field center;
			do {
				if (unreachable = frontier.isEmpty) break;
				center = retrieveFrontier();
			} while(path.contains(center));
			
			if (goalReached = center.type == FieldType.GOAL || unreachable) return goalReached && !unreachable;
			
			path.add(center);
			List neighbours = level.adjacentFields(center).toList();
			neighbours.shuffle();
			frontier.addAll(neighbours.where((f) => f.type != FieldType.WALL && !path.contains(f)));
		}
	}
	
	Field retrieveFrontier();

}

class BreadthFirst extends Search {

	BreadthFirst(Level level) : super(level);

  Field retrieveFrontier() => frontier.removeFirst();
	
}

class DepthFirst extends Search {

	DepthFirst(Level level) : super(level);
	
	Field retrieveFrontier() => frontier.removeLast();

}

class AStar extends Search {

	HashMap<Field, num> fValues = {};

	AStar(Level level) : super(level);

  Field retrieveFrontier() => frontier.reduce((closest, next) {
		calcFValue(Field field) {
			var fValue = fValues[field];
			return fValue == null ?
				fValues[field] = path.indexOf(field) + (level.goal.pos - field.pos).length :
				fValue;   
		}
		return closest != null && calcFValue(closest) < calcFValue(next) ? closest : next;
  });
	
}