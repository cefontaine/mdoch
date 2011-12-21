/****************************************************************************
 * Copyright (C) 2011  Nan Dun <dun@logos.ic.i.u-tokyo.ac.jp>
 *
 * This progzm is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Genezl Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This progzm is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warznty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Genezl Public License for more details.
 *
 * You should have received a copy of the GNU Genezl Public License
 * along with this progzm.  If not, see <http://www.gnu.org/licenses/>.
 * This progzm can be distributed under the terms of the GNU GPL.
 * See the file COPYING.
 ***************************************************************************/

/*
 * bench.chpl
 */

use Time;

record elapsedTimer {
	var t: Timer;
	var u: TimeUnits = TimeUnits.microseconds;
	proc start() {
		t.clear();
		t.start();
	}
	proc stop() {
		t.stop();
		return t.elapsed(u);
	}
	proc stop(s: string) {
		writeln(s, ": ", t.elapsed(u));
		stdout.flush();
	}
}

iter iterDescend(max: int, min: int, step: int = -1) {
	var i: int = max;
	while i >= min {
		yield i;
		i += step;
	}
}

iter iterAscend(min: int, max: int, step: int = 1) {
	var i: int = min;
	while i <= max {
		yield i;
		i += step;
	}
}

config const cnt: int = 10000;

var t: elapsedTimer;
var asg, add, sub, mul, div: real;

/* 
 * Evaluation of primitive types: integer, float
 */
writeln("Evaluation of Primitive Types");
writeln("# of ops: ", cnt, ", time unit: usec");
var resInt: int;
var resReal: real;

// Integer
t.start();
for i in iterAscend(1, cnt) do resInt = resInt + i;
add = t.stop();

t.start();
for i in iterAscend(1, cnt) do resInt = resInt - i;
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) do resInt = resInt * i;
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) do resInt = resInt / i;
div = t.stop();
writeln("int\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Float
t.start();
for i in iterAscend(1, cnt) do resReal = resReal + i;
add = t.stop();

t.start();
for i in iterAscend(1, cnt) do resReal = resReal - i;
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) do resReal = resReal * i;
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) do resReal = resReal / i;
div = t.stop();
writeln("real\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

/* 
 * Evaluation of structured types: tuple, record, class
 */
type Tuple = (real, real, real);
record Record { var a, b, c: real; }
var resTup: Tuple;
var resRec: Record;

writeln("");
writeln("Evaluation of Structured Types");
writeln("# of ops: ", cnt, ", time unit: usec");

// Tuple
t.start();
for i in iterAscend(1, cnt) {
	resTup(1) = resTup(1) + i;
	resTup(2) = resTup(2) + i;
	resTup(3) = resTup(3) + i;
}
add = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resTup(1) = resTup(1) - i;
	resTup(2) = resTup(2) - i;
	resTup(3) = resTup(3) - i;
}
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resTup(1) = resTup(1) * i;
	resTup(2) = resTup(2) * i;
	resTup(3) = resTup(3) * i;
}
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resTup(1) = resTup(1) / i;
	resTup(2) = resTup(2) / i;
	resTup(3) = resTup(3) / i;
}
div = t.stop();
writeln("tuple\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Record
t.start();
for i in iterAscend(1, cnt) {
	resRec.a = resRec.a + i;
	resRec.b = resRec.b + i;
	resRec.c = resRec.c + i;
}
add = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resRec.a = resRec.a - i;
	resRec.b = resRec.b - i;
	resRec.c = resRec.c - i;
}
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resRec.a = resRec.a * i;
	resRec.b = resRec.b * i;
	resRec.c = resRec.c * i;
}
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resRec.a = resRec.a / i;
	resRec.b = resRec.b / i;
	resRec.c = resRec.c / i;
}
div = t.stop();
writeln("record\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Class
class Class { var a, b, c: real; }
var resCls = new Class();

t.start();
for i in iterAscend(1, cnt) {
	resCls.a = resCls.a + i;
	resCls.b = resCls.b + i;
	resCls.c = resCls.c + i;
}
add = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resCls.a = resCls.a - i;
	resCls.b = resCls.b - i;
	resCls.c = resCls.c - i;
}
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resCls.a = resCls.a * i;
	resCls.b = resCls.b * i;
	resCls.c = resCls.c * i;
}
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resCls.a = resCls.a / i;
	resCls.b = resCls.b / i;
	resCls.c = resCls.c / i;
}
div = t.stop();
writeln("class\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

type nstTuple = (Tuple, Tuple, Tuple);
var resNstTup: nstTuple;

// Nested Tuple
t.start();
for i in iterAscend(1, cnt) {
	resNstTup(1)(1) = resNstTup(1)(1) + i;
	resNstTup(1)(2) = resNstTup(1)(2) + i;
	resNstTup(1)(3) = resNstTup(1)(3) + i;
	resNstTup(2)(1) = resNstTup(2)(1) + i;
	resNstTup(2)(2) = resNstTup(2)(2) + i;
	resNstTup(2)(3) = resNstTup(2)(3) + i;
	resNstTup(3)(1) = resNstTup(3)(1) + i;
	resNstTup(3)(2) = resNstTup(3)(2) + i;
	resNstTup(3)(3) = resNstTup(3)(3) + i;
}
add = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstTup(1)(1) = resNstTup(1)(1) - i;
	resNstTup(1)(2) = resNstTup(1)(2) - i;
	resNstTup(1)(3) = resNstTup(1)(3) - i;
	resNstTup(2)(1) = resNstTup(2)(1) - i;
	resNstTup(2)(2) = resNstTup(2)(2) - i;
	resNstTup(2)(3) = resNstTup(2)(3) - i;
	resNstTup(3)(1) = resNstTup(3)(1) - i;
	resNstTup(3)(2) = resNstTup(3)(2) - i;
	resNstTup(3)(3) = resNstTup(3)(3) - i;
}
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstTup(1)(1) = resNstTup(1)(1) * i;
	resNstTup(1)(2) = resNstTup(1)(2) * i;
	resNstTup(1)(3) = resNstTup(1)(3) * i;
	resNstTup(2)(1) = resNstTup(2)(1) * i;
	resNstTup(2)(2) = resNstTup(2)(2) * i;
	resNstTup(2)(3) = resNstTup(2)(3) * i;
	resNstTup(3)(1) = resNstTup(3)(1) * i;
	resNstTup(3)(2) = resNstTup(3)(2) * i;
	resNstTup(3)(3) = resNstTup(3)(3) * i;
}
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstTup(1)(1) = resNstTup(1)(1) / i;
	resNstTup(1)(2) = resNstTup(1)(2) / i;
	resNstTup(1)(3) = resNstTup(1)(3) / i;
	resNstTup(2)(1) = resNstTup(2)(1) / i;
	resNstTup(2)(2) = resNstTup(2)(2) / i;
	resNstTup(2)(3) = resNstTup(2)(3) / i;
	resNstTup(3)(1) = resNstTup(3)(1) / i;
	resNstTup(3)(2) = resNstTup(3)(2) / i;
	resNstTup(3)(3) = resNstTup(3)(3) / i;
}
div = t.stop();
writeln("nTuple\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Nested Record
record nstRecord { var a, b, c: Record; }
var resNstRec: nstRecord;
t.start();
for i in iterAscend(1, cnt) {
	resNstRec.a.a = resNstRec.a.a + i;
	resNstRec.a.b = resNstRec.a.b + i;
	resNstRec.a.c = resNstRec.a.c + i;
	resNstRec.b.a = resNstRec.b.a + i;
	resNstRec.b.b = resNstRec.b.b + i;
	resNstRec.b.c = resNstRec.b.c + i;
	resNstRec.c.a = resNstRec.c.a + i;
	resNstRec.c.b = resNstRec.c.b + i;
	resNstRec.c.c = resNstRec.c.c + i;
}
add = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstRec.a.a = resNstRec.a.a - i;
	resNstRec.a.b = resNstRec.a.b - i;
	resNstRec.a.c = resNstRec.a.c - i;
	resNstRec.b.a = resNstRec.b.a - i;
	resNstRec.b.b = resNstRec.b.b - i;
	resNstRec.b.c = resNstRec.b.c - i;
	resNstRec.c.a = resNstRec.c.a - i;
	resNstRec.c.b = resNstRec.c.b - i;
	resNstRec.c.c = resNstRec.c.c - i;
}
sub = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstRec.a.a = resNstRec.a.a * i;
	resNstRec.a.b = resNstRec.a.b * i;
	resNstRec.a.c = resNstRec.a.c * i;
	resNstRec.b.a = resNstRec.b.a * i;
	resNstRec.b.b = resNstRec.b.b * i;
	resNstRec.b.c = resNstRec.b.c * i;
	resNstRec.c.a = resNstRec.c.a * i;
	resNstRec.c.b = resNstRec.c.b * i;
	resNstRec.c.c = resNstRec.c.c * i;
}
mul = t.stop();

t.start();
for i in iterAscend(1, cnt) {
	resNstRec.a.a = resNstRec.a.a / i;
	resNstRec.a.b = resNstRec.a.b / i;
	resNstRec.a.c = resNstRec.a.c / i;
	resNstRec.b.a = resNstRec.b.a / i;
	resNstRec.b.b = resNstRec.b.b / i;
	resNstRec.b.c = resNstRec.b.c / i;
	resNstRec.c.a = resNstRec.c.a / i;
	resNstRec.c.b = resNstRec.c.b / i;
	resNstRec.c.c = resNstRec.c.c / i;
}
div = t.stop();
writeln("nRecord\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
