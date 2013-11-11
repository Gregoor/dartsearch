library search;

import 'level.dart';
import 'dart:collection';


abstract class Search {

	Level level;
	
	Queue<Field> frontier;
	
	List<Field> path = [];
	
	Search(this.level) {
		frontier = new Queue.from([level.start]);
		findPath();
	}
	
	bool findPath() {
		bool unreachable = false;
		while (frontier.isNotEmpty) {
			Field center;
			do {
				unreachable = frontier.isEmpty;
				center = retrieveFrontier();
			} while(path.contains(center) && !unreachable);
			
			if (unreachable) return null;
			
			path.add(center);
			List neighbours = level.adjacentFields(center).toList();
			neighbours.shuffle();
			frontier.addAll(neighbours.where((f) => f.type != FieldType.WALL && !path.contains(f)));
			
			if (center.type == FieldType.GOAL) return true;
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
	
	Field retrieveFrontier() {
		calcFValue(Field field, [int index]) {
			if (index == null) index = path.indexOf(field);
			var fValue = fValues[field];
			return fValue == null ?
				fValues[field] = index + (level.goal.pos - field.pos).length :
				fValue;   
		}

		Field minF;
		int i = 0;
		frontier.forEach((Field f) {
			if (minF == null || calcFValue(minF) > calcFValue(f, i)) minF = f;
			i++;
		});
		
		frontier.remove(minF);
		return minF;
	}

	
}