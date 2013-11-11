library vector;

import "dart:math";

class Vector {

	final num x, y;

	num _length;

	Vector(num x, num y) : this.x = double.parse(x.toStringAsFixed(3)), this.y = double.parse(y.toStringAsFixed(3));

	Vector.clone(Vector v) : x = v.x, y = v.y;

	Vector.zero() : x = 0, y = 0;

	operator ==(Vector v) => x == v.x && y == v.y;

	operator >(Vector v) => length > v.length;

	operator <(Vector v) => length < v.length;

	operator +(Vector v) => new Vector(x + v.x, y + v.y);

	operator -(Vector v) => new Vector(x - v.x, y - v.y);

	operator *(Vector v) => new Vector(x * v.x, y * v.y);

	operator /(Vector v) => new Vector(x / v.x, y / v.y);

	get length {
		if (_length == null) _length = sqrt(pow(x, 2) + pow(y, 2));
		return _length;
	}

	get neg => new Vector(-x, -y);

	get hashCode => x + y;

	String toString() => "$x / $y";

	Vector normalize() {
		var l = length != 0 ? length : 1;
		num x = this.x / l, y = this.y / l;
		return new Vector(x, y);
	}

	Vector round() => new Vector(x.round(), y. round());

	Vector scale(num n) => new Vector(x * n, y * n);

	Vector plus(num pX, num pY) => new Vector(x + pX, y + pY);

}
