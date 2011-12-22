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
var res, aloc, asg, add, sub, mul, div: real;

/* 
 * Evaluation of primitive types: integer, float
 */
proc primitive_types() {
	var resInt32: int(32);
	var resInt: int(64);

	// Moving outside as global variables achieves 2x speedup
	var resReal32: real(32);
	var resReal: real(64);
	
	writeln("Evaluation of Primitive Types");
	writeln("# of ops: ", cnt, ", time unit: usec");

	// Integer
	t.start();
	for i in iterAscend(1, cnt) do resInt32 = resInt32 + i;
	add = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resInt32 = resInt32 - i;
	sub = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resInt32 = resInt32 * i;
	mul = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resInt32 = resInt32 / i;
	div = t.stop();
	writeln("int32\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resInt32;

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
	writeln("int64\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resInt;

	// Float
	t.start();
	for i in iterAscend(1, cnt) do resReal32 = resReal32 + i: real(32);
	add = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resReal32 = resReal32 - i: real(32);
	sub = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resReal32 = resReal32 * i: real(32);
	mul = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do resReal32 = resReal32 / i: real(32);
	div = t.stop();
	writeln("real32\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resReal32;

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
	writeln("real64\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resReal;
}

/* 
 * Evaluation of structured types: tuple, record, class
 */
type Tuple = (real, real, real);
type nstTuple = (Tuple, Tuple, Tuple);
record Record { var a, b, c: real; }
record nstRecord { var a, b, c: Record; }
class Class { var a, b, c: real; }
class nstClass { var a, b, c: Class; }

proc structed_types() {
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

	t.start();
	for i in iterAscend(1, cnt) {
		resTup(1) = resTup(1) + i;
		resTup(2) = resTup(1) + i;
		resTup(3) = resTup(2) + i;
	}
	add = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resTup(1) = resTup(1) - i;
		resTup(2) = resTup(1) - i;
		resTup(3) = resTup(2) - i;
	}
	sub = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resTup(1) = resTup(1) * i;
		resTup(2) = resTup(1) * i;
		resTup(3) = resTup(2) * i;
	}
	mul = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resTup(1) = resTup(1) / i;
		resTup(2) = resTup(1) / i;
		resTup(3) = resTup(2) / i;
	}
	div = t.stop();
	writeln("xtuple\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

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

	t.start();
	for i in iterAscend(1, cnt) {
		resNstRec.a.a = resNstRec.a.a + i;
		resNstRec.a.b = resNstRec.a.a + i;
		resNstRec.a.c = resNstRec.a.b + i;
		resNstRec.b.a = resNstRec.b.a + i;
		resNstRec.b.b = resNstRec.b.a + i;
		resNstRec.b.c = resNstRec.b.b + i;
		resNstRec.c.a = resNstRec.c.a + i;
		resNstRec.c.b = resNstRec.c.a + i;
		resNstRec.c.c = resNstRec.c.b + i;
	}
	add = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstRec.a.a = resNstRec.a.a - i;
		resNstRec.a.b = resNstRec.a.a - i;
		resNstRec.a.c = resNstRec.a.b - i;
		resNstRec.b.a = resNstRec.b.a - i;
		resNstRec.b.b = resNstRec.b.a - i;
		resNstRec.b.c = resNstRec.b.b - i;
		resNstRec.c.a = resNstRec.c.a - i;
		resNstRec.c.b = resNstRec.c.a - i;
		resNstRec.c.c = resNstRec.c.b - i;
	}
	sub = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstRec.a.a = resNstRec.a.a * i;
		resNstRec.a.b = resNstRec.a.a * i;
		resNstRec.a.c = resNstRec.a.b * i;
		resNstRec.b.a = resNstRec.b.a * i;
		resNstRec.b.b = resNstRec.b.a * i;
		resNstRec.b.c = resNstRec.b.b * i;
		resNstRec.c.a = resNstRec.c.a * i;
		resNstRec.c.b = resNstRec.c.a * i;
		resNstRec.c.c = resNstRec.c.b * i;
	}
	mul = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstRec.a.a = resNstRec.a.a / i;
		resNstRec.a.b = resNstRec.a.a / i;
		resNstRec.a.c = resNstRec.a.b / i;
		resNstRec.b.a = resNstRec.b.a / i;
		resNstRec.b.b = resNstRec.b.a / i;
		resNstRec.b.c = resNstRec.b.b / i;
		resNstRec.c.a = resNstRec.c.a / i;
		resNstRec.c.b = resNstRec.c.a / i;
		resNstRec.c.c = resNstRec.c.b / i;
	}
	div = t.stop();
	writeln("xnRecord\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Nested Class
	var resNstCls = new nstClass();
	resNstCls.a = new Class();
	resNstCls.b = new Class();
	resNstCls.c = new Class();
	t.start();
	for i in iterAscend(1, cnt) {
		resNstCls.a.a = resNstCls.a.a + i;
		resNstCls.a.b = resNstCls.a.b + i;
		resNstCls.a.c = resNstCls.a.c + i;
		resNstCls.b.a = resNstCls.b.a + i;
		resNstCls.b.b = resNstCls.b.b + i;
		resNstCls.b.c = resNstCls.b.c + i;
		resNstCls.c.a = resNstCls.c.a + i;
		resNstCls.c.b = resNstCls.c.b + i;
		resNstCls.c.c = resNstCls.c.c + i;
	}
	add = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstCls.a.a = resNstCls.a.a - i;
		resNstCls.a.b = resNstCls.a.b - i;
		resNstCls.a.c = resNstCls.a.c - i;
		resNstCls.b.a = resNstCls.b.a - i;
		resNstCls.b.b = resNstCls.b.b - i;
		resNstCls.b.c = resNstCls.b.c - i;
		resNstCls.c.a = resNstCls.c.a - i;
		resNstCls.c.b = resNstCls.c.b - i;
		resNstCls.c.c = resNstCls.c.c - i;
	}
	sub = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstCls.a.a = resNstCls.a.a * i;
		resNstCls.a.b = resNstCls.a.b * i;
		resNstCls.a.c = resNstCls.a.c * i;
		resNstCls.b.a = resNstCls.b.a * i;
		resNstCls.b.b = resNstCls.b.b * i;
		resNstCls.b.c = resNstCls.b.c * i;
		resNstCls.c.a = resNstCls.c.a * i;
		resNstCls.c.b = resNstCls.c.b * i;
		resNstCls.c.c = resNstCls.c.c * i;
	}
	mul = t.stop();

	t.start();
	for i in iterAscend(1, cnt) {
		resNstCls.a.a = resNstCls.a.a / i;
		resNstCls.a.b = resNstCls.a.b / i;
		resNstCls.a.c = resNstCls.a.c / i;
		resNstCls.b.a = resNstCls.b.a / i;
		resNstCls.b.b = resNstCls.b.b / i;
		resNstCls.b.c = resNstCls.b.c / i;
		resNstCls.c.a = resNstCls.c.a / i;
		resNstCls.c.b = resNstCls.c.b / i;
		resNstCls.c.c = resNstCls.c.c / i;
	}
	div = t.stop();
	writeln("nClass\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
}

proc parallel_types() {
	/* 
	 * Evaluation of data parallel types: range, domain, array
	 */
    var resInt: int;	
	writeln("");
	writeln("Evaluation of Data Parellel Types");
	writeln("# of ops: ", cnt, ", time unit: usec");

	var loopDom, loopRange, loopIter: real;

	// Range Type
	t.start();
	for i in iterAscend(1, cnt) do
		for j in [1..1] do resInt += i;
	loopDom = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do
		for j in 1..1 do resInt += i;
	loopRange = t.stop();

	t.start();
	for i in iterAscend(1, cnt) do
		for j in iterAscend(1, 1) do resInt += i;
	loopIter = t.stop();
	writeln("     \t\t", "domain\t\t\t", "range\t\t\t", "iterator");
	writeln("loop\t\t",loopDom,"\t\t",loopRange,"\t\t",loopIter);

	// Domain and Array
	var rctDom1D: domain(1);	// rectangular domain
	var irrDom1D: domain(int);			// irregular domain
	var dim2d, dim3d: int;
	dim2d = sqrt(cnt): int;
	dim3d = cbrt(cnt): int;
	writeln("");
	writeln("# of ops: ", cnt, ", 2D domain: ", dim2d, "x", dim2d, 
		", 3D domain: ", dim3d, "x", dim3d, "x", dim3d, ", time unit: usec");

	// 1D domain
	t.start();
	rctDom1D = [1..cnt];
	aloc = t.stop();

	t.start();
	for d in rctDom1D do resInt = resInt + d;
	add = t.stop();

	t.start();
	for d in rctDom1D do resInt = resInt - d;
	sub = t.stop();

	t.start();
	for d in rctDom1D do resInt = resInt * d;
	mul = t.stop();

	t.start();
	for d in rctDom1D do resInt = resInt / d;
	div = t.stop();
	writeln("1D-rctDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	t.start();
	irrDom1D = [1..cnt];
	aloc = t.stop();

	t.start();
	for d in irrDom1D do resInt = resInt + d;
	add = t.stop();

	t.start();
	for d in irrDom1D do resInt = resInt - d;
	sub = t.stop();

	t.start();
	for d in irrDom1D do resInt = resInt * d;
	mul = t.stop();

	t.start();
	for d in irrDom1D do resInt = resInt / d;
	div = t.stop();
	writeln("1D-irrDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	// 2D domain
	var rctDom2D: domain(2);	// rectangular domain
	var irrDom2D: domain(2*int);// irregular domain

	t.start();
	rctDom2D = [1..dim2d, 1..dim2d];
	aloc = t.stop();

	t.start();
	for d in rctDom2D do resInt = resInt + d(2);
	add = t.stop();

	t.start();
	for d in rctDom2D do resInt = resInt - d(2);
	sub = t.stop();

	t.start();
	for d in rctDom2D do resInt = resInt * d(2);
	mul = t.stop();

	t.start();
	for d in rctDom2D do resInt = resInt / d(2);
	div = t.stop();
	writeln("2D-rctDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	t.start();
	irrDom2D = [1..dim2d, 1..dim2d];
	aloc = t.stop();

	t.start();
	for d in irrDom2D do resInt = resInt + d(1);
	add = t.stop();

	t.start();
	for d in irrDom2D do resInt = resInt - d(1);
	sub = t.stop();

	t.start();
	for d in irrDom2D do resInt = resInt * d(1);
	mul = t.stop();

	t.start();
	for d in irrDom2D do resInt = resInt / d(1);
	div = t.stop();
	writeln("2D-irrDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	// 3D domain
	var rctDom3D: domain(3);			// rectangular domain
	var irrDom3D: domain(3*int);		// irregular domain

	t.start();
	rctDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
	aloc = t.stop();

	t.start();
	for d in rctDom3D do resInt = resInt + d(3);
	add = t.stop();

	t.start();
	for d in rctDom3D do resInt = resInt - d(3);
	sub = t.stop();

	t.start();
	for d in rctDom3D do resInt = resInt * d(3);
	mul = t.stop();

	t.start();
	for d in rctDom3D do resInt = resInt / d(3);
	div = t.stop();
	writeln("3D-rctDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	t.start();
	irrDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
	aloc = t.stop();

	t.start();
	for d in irrDom3D do resInt = resInt + d(1);
	add = t.stop();

	t.start();
	for d in irrDom3D do resInt = resInt - d(1);
	sub = t.stop();

	t.start();
	for d in irrDom3D do resInt = resInt * d(1);
	mul = t.stop();

	t.start();
	for d in irrDom3D do resInt = resInt / d(1);
	div = t.stop();
	writeln("3D-irrDom\t",aloc,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	// 1D array
	writeln("");
	writeln("\t\taloc\t\tasg\t\tadd\t\tsub\t\tmul\t\tdiv"); 
	var rDom1D: domain(1);	// rectangular domain
	var rctArr1D: [rDom1D] int;
	t.start();
	rDom1D = [1..cnt]; // with array allocation
	aloc = t.stop();

	t.start();
	for a in rctArr1D do a = 1;
	asg = t.stop();

	t.start();
	for a in rctArr1D do resInt = resInt + a;
	add = t.stop();

	t.start();
	for a in rctArr1D do resInt = resInt - a;
	sub = t.stop();

	t.start();
	for a in rctArr1D do resInt = resInt * a;
	mul = t.stop();

	t.start();
	for a in rctArr1D do resInt = resInt / a;
	div = t.stop();
	writeln("1D-rctArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	var iDom1D: domain(int);	// rectangular domain
	var irrArr1D: [iDom1D] int;
	t.start();
	iDom1D = [1..cnt]; // with array allocation
	aloc = t.stop();

	t.start();
	for a in irrArr1D do a = 1;
	asg = t.stop();

	t.start();
	for a in irrArr1D do resInt = resInt + a;
	add = t.stop();

	t.start();
	for a in irrArr1D do resInt = resInt - a;
	sub = t.stop();

	t.start();
	for a in irrArr1D do resInt = resInt * a;
	mul = t.stop();

	t.start();
	for a in irrArr1D do resInt = resInt / a;
	div = t.stop();
	writeln("1D-irrArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	// 2D array
	var rDom2D: domain(2);
	var rctArr2D: [rDom2D] int;
	t.start();
	rDom2D = [1..dim2d, 1..dim2d];
	aloc = t.stop();

	t.start();
	for a in rctArr2D do a = 1; 
	asg = t.stop();

	t.start();
	for a in rctArr2D do resInt = resInt + a; 
	add = t.stop();

	t.start();
	for a in rctArr2D do resInt = resInt - a; 
	sub = t.stop();

	t.start();
	for a in rctArr2D do resInt = resInt * a; 
	mul = t.stop();

	t.start();
	for a in rctArr2D do resInt = resInt / a; 
	div = t.stop();
	writeln("2D-rctArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	var iDom2D: domain(2*int);
	var irrArr2D: [iDom2D] int;
	t.start();
	iDom2D = [1..dim2d, 1..dim2d];
	aloc = t.stop();

	t.start();
	for a in irrArr2D do a = 1;
	asg = t.stop();

	t.start();
	for a in irrArr2D do resInt = resInt + a;
	add = t.stop();

	t.start();
	for a in irrArr2D do resInt = resInt - a;
	sub = t.stop();

	t.start();
	for a in irrArr2D do resInt = resInt * a;
	mul = t.stop();

	t.start();
	for a in irrArr2D do resInt = resInt / a;
	div = t.stop();
	writeln("2D-irrArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	// 3D array
	var rDom3D: domain(3);			// rectangular domain
	var rctArr3D: [rDom3D] int;

	t.start();
	rDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
	aloc = t.stop();

	t.start();
	for a in rctArr3D do a = 1;
	asg = t.stop();

	t.start();
	for a in rctArr3D do resInt = resInt + a;
	add = t.stop();

	t.start();
	for a in rctArr3D do resInt = resInt - a;
	sub = t.stop();

	t.start();
	for a in rctArr3D do resInt = resInt * a;
	mul = t.stop();

	t.start();
	for a in rctArr3D do resInt = resInt / a;
	div = t.stop();
	writeln("3D-rctArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);

	var iDom3D: domain(3*int);		// irregular domain
	var irrArr3D: [iDom3D] int;

	t.start();
	iDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
	aloc = t.stop();

	t.start();
	for a in irrArr3D do a = 1;
	asg = t.stop();

	t.start();
	for a in irrArr3D do resInt = resInt + a;
	add = t.stop();

	t.start();
	for a in irrArr3D do resInt = resInt - a;
	sub = t.stop();

	t.start();
	for a in irrArr3D do resInt = resInt * a;
	mul = t.stop();

	t.start();
	for a in irrArr3D do resInt = resInt / a;
	div = t.stop();
	writeln("3D-irrArr\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
			"\t\t",mul,"\t\t",div);
}

proc main() {
	primitive_types();
}
