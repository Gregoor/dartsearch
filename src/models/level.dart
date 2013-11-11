library level;

import 'dart:math';
import 'vector.dart';

class Level {

	List<List<Field>> fields;
	
	Field start, goal;
	
	Level.fromAsciiString(String string) {
			List rows = string.split('\n');
			int width = rows[0].length, height = rows.length;
			initFields(width, height);
			for (int x = 0; x < width; x++) {
				for (int y = 0; y < height; y++) {
					Field field = fields[x][y] = new Field(x, y);
					FieldType type;
					switch (rows[y][x]) {
						case ' ':
						type = FieldType.EMPTY;
						break;
					case 'x':
						type = FieldType.WALL;
						break;
					case 's':
						type = FieldType.START;
						start = field;
						break;
					case 'g':
						type = FieldType.GOAL;
						goal = field;
						break;
					default:
						throw new FormatException('Invalid field type');
					}
					field.type = type;
				}
			}
	}
	
	Level.random(int width, int height) {
		initFields(width, height);
		
		Random rand = new Random();
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				FieldType type = min(x, y) == 0 || x + 1 >= width || y + 1 >= height 
					|| rand.nextInt(5) == 1 ?
					FieldType.WALL : FieldType.EMPTY;
				fields[x][y] = new Field(x, y, type);
			}
		}
		
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				Field field = fields[x][y];
				int adjacentWalls = adjacentFields(field).where((Field field) => field.type == FieldType.WALL).length;
				if (adjacentWalls == 4 || (adjacentWalls == 2 && adjacentWalls * rand.nextDouble() > .7)) {
					field.type = FieldType.WALL;				
				}
			}
		}
		
		var missingFields = [FieldType.START, FieldType.GOAL];
		while (missingFields.isNotEmpty) {
			FieldType type = missingFields.first;

			Field field;
			do {
				field = fields[rand.nextInt(width - 2) + 1][rand.nextInt(height - 2) + 1];
			} while (
				field.type != FieldType.EMPTY ||
				adjacentFields(field).any((Field neighbour) => [FieldType.GOAL, FieldType.START].contains(neighbour.type))
			);
			field.type = type;
			switch (type) {
				case FieldType.START:
					start = field;
					break;
				case FieldType.GOAL:
					goal = field;
					break;
			}
			
			missingFields.remove(type);
		}
	}
	
	initFields(int width, int height) {
		fields = new List(width);
		fields = fields.map((el) => new List(height)).toList(growable: true);
	}
	
	Iterable adjacentFields(Field center) {
		Vector pos = center.pos;
		List<Vector> neighbours = [pos.plus(0, 1), pos.plus(0, -1), pos.plus(1, 0), pos.plus(-1, 0)];
		return neighbours.where((Vector v) {
			num x = v.x, y = v.y;
			return x * y > 0 && x < width && y < height;		
		}).map((Vector pos) => fields[pos.x.toInt()][pos.y.toInt()]); 
	}
	
	get width => fields.length;
	
	get height => fields[0].length;
	
}

class FieldType {
	static const EMPTY = const FieldType._(0);

	static const WALL = const FieldType._(1);

	static const START = const FieldType._(2);

	static const GOAL = const FieldType._(3);

	static get values => [EMPTY, WALL, START, GOAL];

	final int value;

	const FieldType._(this.value);

	int get hashCode => value;
}

class Field {

	Vector pos;
	FieldType type;
	
	bool visited = false;
	
	Field(int x, int y, [this.type]) : pos = new Vector(x, y);
	
	toString() => "$pos";
	
}
