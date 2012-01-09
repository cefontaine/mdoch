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

type Tuple = (real, real, real);
type nstTuple = (Tuple, Tuple, Tuple);
record Record { var a, b, c: real; }
record nstRecord { var a, b, c: Record; }
class Class { var a, b, c: real; }
class nstClass { var a, b, c: Class; }

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

proc =(a: Tuple, b: int) {
	var r: Tuple;
	r(1) = b;
	r(2) = b;
	r(3) = b;
	return r;
}

proc +(a: Tuple, b: int) {
	var r: Tuple;
	r(1) = a(1) + b;
	r(2) = a(2) + b;
	r(3) = a(3) + b;
	return r;
}

proc -(a: Tuple, b: int) {
	var r: Tuple;
	r(1) = a(1) - b;
	r(2) = a(2) - b;
	r(3) = a(3) - b;
	return r;
}

proc *(a: Tuple, b: int) {
	var r: Tuple;
	r(1) = a(1) * b;
	r(2) = a(2) * b;
	r(3) = a(3) * b;
	return r;
}

proc /(a: Tuple, b: int) {
	var r: Tuple;
	r(1) = a(1) / b;
	r(2) = a(2) / b;
	r(3) = a(3) / b;
	return r;
}

proc =(a: Record, b: int) {
	var r: Record;
	r.a = b;
	r.b = b;
	r.c = b;
	return r;
}

proc +(a: Record, b: int) {
	var r: Record;
	r.a = a.a + b;
	r.b = a.b + b;
	r.c = a.c + b;
	return r;
}

proc -(a: Record, b: int) {
	var r: Record;
	r.a = a.a + b;
	r.b = a.b + b;
	r.c = a.c + b;
	return r;
}

proc *(a: Record, b: int) {
	var r: Record;
	r.a = a.a * b;
	r.b = a.b * b;
	r.c = a.c * b;
	return r;
}

proc /(a: Record, b: int) {
	var r: Record;
	r.a = a.a / b;
	r.b = a.b / b;
	r.c = a.c / b;
	return r;
}

proc +(a: Record, b: Record) {
	var r: Record;
	r.a = a.a + b.a;
	r.b = a.b + b.b;
	r.c = a.c + b.c;
	return r;
}

proc -(a: Record, b: Record) {
	var r: Record;
	r.a = a.a - b.a;
	r.b = a.b - b.b;
	r.c = a.c - b.c;
	return r;
}

proc =(a: Class, b: int) {
	a.a = b;
	a.b = b;
	a.c = b;
	return a;
}

proc +(a: Class, b: int) {
	a.a = a.a + b;
	a.b = a.b + b;
	a.c = a.c + b;
	return a;
}

proc -(a: Class, b: int) {
	a.a = a.a + b;
	a.b = a.b + b;
	a.c = a.c + b;
	return a;
}

proc *(a: Class, b: int) {
	a.a = a.a * b;
	a.b = a.b * b;
	a.c = a.c * b;
	return a;
}

proc /(a: Class, b: int) {
	a.a = a.a / b;
	a.b = a.b / b;
	a.c = a.c / b;
	return a;
}

proc =(a:nstTuple, b: int) {
	var r: nstTuple;
	r(1)(1) = b;
	r(1)(2) = b;
	r(1)(3) = b;
	r(2)(1) = b;
	r(2)(2) = b;
	r(2)(3) = b;
	r(3)(1) = b;
	r(3)(2) = b;
	r(3)(3) = b;
	return r;
}

proc +(a:nstTuple, b: int) {
	var r: nstTuple;
	r(1)(1) = a(1)(1) + b;
	r(1)(2) = a(1)(2) + b;
	r(1)(3) = a(1)(3) + b;
	r(2)(1) = a(2)(1) + b;
	r(2)(2) = a(2)(2) + b;
	r(2)(3) = a(2)(3) + b;
	r(3)(1) = a(3)(1) + b;
	r(3)(2) = a(3)(2) + b;
	r(3)(3) = a(3)(3) + b;
	return r;
}

proc -(a:nstTuple, b: int) {
	var r: nstTuple;
	r(1)(1) = a(1)(1) - b;
	r(1)(2) = a(1)(2) - b;
	r(1)(3) = a(1)(3) - b;
	r(2)(1) = a(2)(1) - b;
	r(2)(2) = a(2)(2) - b;
	r(2)(3) = a(2)(3) - b;
	r(3)(1) = a(3)(1) - b;
	r(3)(2) = a(3)(2) - b;
	r(3)(3) = a(3)(3) - b;
	return r;
}

proc *(a:nstTuple, b: int) {
	var r: nstTuple;
	r(1)(1) = a(1)(1) * b;
	r(1)(2) = a(1)(2) * b;
	r(1)(3) = a(1)(3) * b;
	r(2)(1) = a(2)(1) * b;
	r(2)(2) = a(2)(2) * b;
	r(2)(3) = a(2)(3) * b;
	r(3)(1) = a(3)(1) * b;
	r(3)(2) = a(3)(2) * b;
	r(3)(3) = a(3)(3) * b;
	return r;
}

proc /(a:nstTuple, b: int) {
	var r: nstTuple;
	r(1)(1) = a(1)(1) / b;
	r(1)(2) = a(1)(2) / b;
	r(1)(3) = a(1)(3) / b;
	r(2)(1) = a(2)(1) / b;
	r(2)(2) = a(2)(2) / b;
	r(2)(3) = a(2)(3) / b;
	r(3)(1) = a(3)(1) / b;
	r(3)(2) = a(3)(2) / b;
	r(3)(3) = a(3)(3) / b;
	return r;
}

proc =(a:nstRecord, b: int) {
	var r: nstRecord;
	r.a.a = b;
	r.a.b = b;
	r.a.c = b;
	r.b.a = b;
	r.b.b = b;
	r.b.c = b;
	r.c.a = b;
	r.c.b = b;
	r.c.c = b;
	return r;
}

proc +(a:nstRecord, b: int) {
	var r: nstRecord;
	r.a.a = a.a.a + b;
	r.a.b = a.a.b + b;
	r.a.c = a.a.c + b;
	r.b.a = a.b.a + b;
	r.b.b = a.b.b + b;
	r.b.c = a.b.c + b;
	r.c.a = a.c.a + b;
	r.c.b = a.c.b + b;
	r.c.c = a.c.c + b;
	return r;
}

proc -(a:nstRecord, b: int) {
	var r: nstRecord;
	r.a.a = a.a.a - b;
	r.a.b = a.a.b - b;
	r.a.c = a.a.c - b;
	r.b.a = a.b.a - b;
	r.b.b = a.b.b - b;
	r.b.c = a.b.c - b;
	r.c.a = a.c.a - b;
	r.c.b = a.c.b - b;
	r.c.c = a.c.c - b;
	return r;
}

proc *(a:nstRecord, b: int) {
	var r: nstRecord;
	r.a.a = a.a.a * b;
	r.a.b = a.a.b * b;
	r.a.c = a.a.c * b;
	r.b.a = a.b.a * b;
	r.b.b = a.b.b * b;
	r.b.c = a.b.c * b;
	r.c.a = a.c.a * b;
	r.c.b = a.c.b * b;
	r.c.c = a.c.c * b;
	return r;
}

proc /(a:nstRecord, b: int) {
	var r: nstRecord;
	r.a.a = a.a.a / b;
	r.a.b = a.a.b / b;
	r.a.c = a.a.c / b;
	r.b.a = a.b.a / b;
	r.b.b = a.b.b / b;
	r.b.c = a.b.c / b;
	r.c.a = a.c.a / b;
	r.c.b = a.c.b / b;
	r.c.c = a.c.c / b;
	return r;
}

proc =(a:nstClass, b: int) {
	a.a.a = b;
	a.a.b = b;
	a.a.c = b;
	a.b.a = b;
	a.b.b = b;
	a.b.c = b;
	a.c.a = b;
	a.c.b = b;
	a.c.c = b;
	return a;
}

proc +(a:nstClass, b: int) {
	a.a.a = a.a.a + b;
	a.a.b = a.a.b + b;
	a.a.c = a.a.c + b;
	a.b.a = a.b.a + b;
	a.b.b = a.b.b + b;
	a.b.c = a.b.c + b;
	a.c.a = a.c.a + b;
	a.c.b = a.c.b + b;
	a.c.c = a.c.c + b;
	return a;
}

proc -(a:nstClass, b: int) {
	a.a.a = a.a.a - b;
	a.a.b = a.a.b - b;
	a.a.c = a.a.c - b;
	a.b.a = a.b.a - b;
	a.b.b = a.b.b - b;
	a.b.c = a.b.c - b;
	a.c.a = a.c.a - b;
	a.c.b = a.c.b - b;
	a.c.c = a.c.c - b;
	return a;
}

proc *(a:nstClass, b: int) {
	a.a.a = a.a.a * b;
	a.a.b = a.a.b * b;
	a.a.c = a.a.c * b;
	a.b.a = a.b.a * b;
	a.b.b = a.b.b * b;
	a.b.c = a.b.c * b;
	a.c.a = a.c.a * b;
	a.c.b = a.c.b * b;
	a.c.c = a.c.c * b;
	return a;
}

proc /(a:nstClass, b: int) {
	a.a.a = a.a.a / b;
	a.a.b = a.a.b / b;
	a.a.c = a.a.c / b;
	a.b.a = a.b.a / b;
	a.b.b = a.b.b / b;
	a.b.c = a.b.c / b;
	a.c.a = a.c.a / b;
	a.c.b = a.c.b / b;
	a.c.c = a.c.c / b;
	return a;
}

config const n: int = 10000;

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
	writeln("# of ops: ", n, ", time unit: usec");

	// Integer
	t.start();
	for i in iterAscend(1, n) do resInt32 = resInt32 + i;
	add = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt32 = resInt32 - i;
	sub = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt32 = resInt32 * i;
	mul = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt32 = resInt32 / i;
	div = t.stop();
	writeln("int32\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resInt32;

	t.start();
	for i in iterAscend(1, n) do resInt = resInt + i;
	add = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt = resInt - i;
	sub = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt = resInt * i;
	mul = t.stop();

	t.start();
	for i in iterAscend(1, n) do resInt = resInt / i;
	div = t.stop();
	writeln("int64\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resInt;

	// Float
	t.start();
	for i in iterAscend(1, n) do resReal32 = resReal32 + i: real(32);
	add = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal32 = resReal32 - i: real(32);
	sub = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal32 = resReal32 * i: real(32);
	mul = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal32 = resReal32 / i: real(32);
	div = t.stop();
	writeln("real32\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resReal32;

	t.start();
	for i in iterAscend(1, n) do resReal = resReal + i;
	add = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal = resReal - i;
	sub = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal = resReal * i;
	mul = t.stop();

	t.start();
	for i in iterAscend(1, n) do resReal = resReal / i;
	div = t.stop();
	writeln("real64\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resReal;
}

proc parallel_types() {
	/* 
	 * Evaluation of data parallel types: range, domain, array
	 */
    var resInt: int;	
	writeln("");
	writeln("Evaluation of Data Parellel Types");
	writeln("# of ops: ", n, ", time unit: usec");

	var loopDom, loopRange, loopIter, loopPredom: real;

	// Range Type
	t.start();
	for i in iterAscend(1, n) do
		for j in [1..1] do resInt += i;
	loopDom = t.stop();

	t.start();
	for i in iterAscend(1, n) do
		for j in 1..1 do resInt += i;
	loopRange = t.stop();

	t.start();
	for i in iterAscend(1, n) do
		for j in iterAscend(1, 1) do resInt += i;
	loopIter = t.stop();

	var preDom = [1..1];
	t.start();
	for i in iterAscend(1, n) do
		for j in preDom do resInt += i;
	loopPredom = t.stop();
	
	writeln("     \t\t", "domain\t\t\t", "range\t\t\t", "iterator\t\t\t",
		"ForwardedDom");
	writeln("loop\t\t",loopDom,"\t\t",loopRange,"\t\t",loopIter,"\t\t",
		loopPredom);
	res = resInt;

	// Domain and Array
	var rctDom1D: domain(1);	// rectangular domain
	var irrDom1D: domain(int);			// irregular domain
	var dim2d, dim3d: int;
	dim2d = sqrt(n): int;
	dim3d = cbrt(n): int;
	writeln("");
	writeln("# of ops: ", n, ", 2D domain: ", dim2d, "x", dim2d, 
		", 3D domain: ", dim3d, "x", dim3d, "x", dim3d, ", time unit: usec");

	// 1D domain
	t.start();
	rctDom1D = [1..n];
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
	res = resInt;

	t.start();
	irrDom1D = [1..n];
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
	res = resInt;

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
	res = resInt;

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
	res = resInt;

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
	res = resInt;

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
	res = resInt;

	// 1D array
	writeln("");
	writeln("\t\taloc\t\tasg\t\tadd\t\tsub\t\tmul\t\tdiv"); 
	var rDom1D: domain(1);	// rectangular domain
	var rctArr1D: [rDom1D] int;
	t.start();
	rDom1D = [1..n]; // with array allocation
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
	res = resInt;

	var iDom1D: domain(int);	// rectangular domain
	var irrArr1D: [iDom1D] int;
	t.start();
	iDom1D = [1..n]; // with array allocation
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
	res = resInt;

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
	res = resInt;

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
	res = resInt;

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
	res = resInt;

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
	res = resInt;
}

proc array_with_types_r() {
	var arrDom1D: domain(1);	// rectangular domain
	var arrInt: [arrDom1D] int;
	var arrReal: [arrDom1D] real;
	var arrTup: [arrDom1D] Tuple;
	var arrRec: [arrDom1D] Record;
	var arrNstTup: [arrDom1D] nstTuple;
	var arrNstRec: [arrDom1D] nstRecord;
	var resInt: int;
	var resReal: real;
	var resTup: Tuple;
	var resRec: Record;
	var resNstTup: nstTuple;
	var resNstRec: nstRecord;

	arrDom1D = [1..n];
	
	/* 
	   The operation includes both memory read, (except assignment)
	   thus the performance analysis should be careful.
	 */
	writeln("Evaluation of Array with Types (Read Only)");
	writeln("# of ops: ", n, ", time unit: usec");

	// Int Array
	t.start();
	for d in arrInt.domain do arrInt(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrInt.domain do resInt = resInt + arrInt(d); 
	add = t.stop();
	
	t.start();
	for d in arrInt.domain do resInt = resInt - arrInt(d);
	sub = t.stop();
	
	t.start();
	for d in arrInt.domain do resInt = resInt * arrInt(d);
	mul = t.stop();
	
	t.start();
	for d in arrInt.domain do resInt = resInt /  arrInt(d);
	div = t.stop();
	res = resInt;
	writeln("intArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Real Array
	t.start();
	for d in arrReal.domain do arrReal(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrReal.domain do resReal = resReal + arrReal(d); 
	add = t.stop();
	
	t.start();
	for d in arrReal.domain do resReal = resReal - arrReal(d);
	sub = t.stop();
	
	t.start();
	for d in arrReal.domain do resReal = resReal * arrReal(d);
	mul = t.stop();
	
	t.start();
	for d in arrReal.domain do resReal = resReal / arrReal(d);
	div = t.stop();
	res = resReal;
	writeln("realArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Tuple Array
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = d;
		arrTup(d)(2) = d;
		arrTup(d)(3) = d;
	}
	asg = t.stop();
	
	t.start();
	for a in arrTup {
		resTup(1) = resTup(1) + a(1);
		resTup(2) = resTup(2) + a(2);
		resTup(3) = resTup(3) + a(3);
	}
	add = t.stop();
	
	t.start();
	for a in arrTup {
		resTup(1) = resTup(1) - a(1);
		resTup(2) = resTup(2) - a(2);
		resTup(3) = resTup(3) - a(3);
	}
	sub = t.stop();
	
	t.start();
	for a in arrTup {
		resTup(1) = resTup(1) * a(1);
		resTup(2) = resTup(2) * a(2);
		resTup(3) = resTup(3) * a(3);
	}
	mul = t.stop();
	
	t.start();
	for a in arrTup {
		resTup(1) = resTup(1) / a(1);
		resTup(2) = resTup(2) / a(2);
		resTup(3) = resTup(3) / a(3);
	}
	div = t.stop();
	res = res + resTup(1) + resTup(2) + resTup(3);
	writeln("tupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Record Array
	t.start();
	for d in arrRec.domain {
		arrRec(d).a = d;
		arrRec(d).b = d;
		arrRec(d).c = d;
	}
	asg = t.stop();
	
	t.start();
	for a in arrRec {
		resRec.a = resRec.a + a.a;
		resRec.b = resRec.b + a.b;
		resRec.c = resRec.c + a.c;
	}
	add = t.stop();

	t.start();
	for a in arrRec {
		resRec.a = resRec.a - a.a;
		resRec.b = resRec.b - a.b;
		resRec.c = resRec.c - a.c;
	}
	sub = t.stop();

	t.start();
	for a in arrRec {
		resRec.a = resRec.a * a.a;
		resRec.b = resRec.b * a.b;
		resRec.c = resRec.c * a.c;
	}
	mul = t.stop();

	t.start();
	for a in arrRec {
		resRec.a = resRec.a / a.a;
		resRec.b = resRec.b / a.b;
		resRec.c = resRec.c / a.c;
	}
	div = t.stop();
	res = res + resRec.a + resRec.b + resRec.c;
	writeln("recordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resRec.a;

	// Nested Tuple
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = d;
		arrNstTup(d)(1)(2) = d;
		arrNstTup(d)(1)(3) = d;
		arrNstTup(d)(2)(1) = d;
		arrNstTup(d)(2)(2) = d;
		arrNstTup(d)(2)(3) = d;
		arrNstTup(d)(3)(1) = d;
		arrNstTup(d)(3)(2) = d;
		arrNstTup(d)(3)(3) = d;
	}
	asg = t.stop();
	
	t.start();
	for a in arrNstTup {
		resNstTup(1)(1) = resNstTup(1)(1) + a(1)(1);
		resNstTup(1)(2) = resNstTup(1)(2) + a(1)(2);
		resNstTup(1)(3) = resNstTup(1)(3) + a(1)(3);
		resNstTup(2)(1) = resNstTup(2)(1) + a(2)(1);
		resNstTup(2)(2) = resNstTup(2)(2) + a(2)(2);
		resNstTup(2)(3) = resNstTup(2)(3) + a(2)(3);
		resNstTup(3)(1) = resNstTup(3)(1) + a(3)(1);
		resNstTup(3)(2) = resNstTup(3)(2) + a(3)(2);
		resNstTup(3)(3) = resNstTup(3)(3) + a(3)(3);
	}
	add = t.stop();
	
	t.start();
	for a in arrNstTup {
		resNstTup(1)(1) = resNstTup(1)(1) - a(1)(1);
		resNstTup(1)(2) = resNstTup(1)(2) - a(1)(2);
		resNstTup(1)(3) = resNstTup(1)(3) - a(1)(3);
		resNstTup(2)(1) = resNstTup(2)(1) - a(2)(1);
		resNstTup(2)(2) = resNstTup(2)(2) - a(2)(2);
		resNstTup(2)(3) = resNstTup(2)(3) - a(2)(3);
		resNstTup(3)(1) = resNstTup(3)(1) - a(3)(1);
		resNstTup(3)(2) = resNstTup(3)(2) - a(3)(2);
		resNstTup(3)(3) = resNstTup(3)(3) - a(3)(3);
	}
	sub = t.stop();
	
	t.start();
	for a in arrNstTup {
		resNstTup(1)(1) = resNstTup(1)(1) * a(1)(1);
		resNstTup(1)(2) = resNstTup(1)(2) * a(1)(2);
		resNstTup(1)(3) = resNstTup(1)(3) * a(1)(3);
		resNstTup(2)(1) = resNstTup(2)(1) * a(2)(1);
		resNstTup(2)(2) = resNstTup(2)(2) * a(2)(2);
		resNstTup(2)(3) = resNstTup(2)(3) * a(2)(3);
		resNstTup(3)(1) = resNstTup(3)(1) * a(3)(1);
		resNstTup(3)(2) = resNstTup(3)(2) * a(3)(2);
		resNstTup(3)(3) = resNstTup(3)(3) * a(3)(3);
	}
	mul = t.stop();
	
	t.start();
	for a in arrNstTup {
		resNstTup(1)(1) = resNstTup(1)(1) / a(1)(1);
		resNstTup(1)(2) = resNstTup(1)(2) / a(1)(2);
		resNstTup(1)(3) = resNstTup(1)(3) / a(1)(3);
		resNstTup(2)(1) = resNstTup(2)(1) / a(2)(1);
		resNstTup(2)(2) = resNstTup(2)(2) / a(2)(2);
		resNstTup(2)(3) = resNstTup(2)(3) / a(2)(3);
		resNstTup(3)(1) = resNstTup(3)(1) / a(3)(1);
		resNstTup(3)(2) = resNstTup(3)(2) / a(3)(2);
		resNstTup(3)(3) = resNstTup(3)(3) / a(3)(3);
	}
	div = t.stop();
	res = res + resNstTup(1)(1) + resNstTup(2)(1) + resNstTup(3)(1);
	writeln("nTupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Nested Record
	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = d;
		arrNstRec(d).a.b = d;
		arrNstRec(d).a.c = d;
		arrNstRec(d).b.a = d;
		arrNstRec(d).b.b = d;
		arrNstRec(d).b.c = d;
		arrNstRec(d).c.a = d;
		arrNstRec(d).c.b = d;
		arrNstRec(d).c.c = d;
	}
	asg = t.stop();
	t.start();
	for a in arrNstRec do {
		resNstRec.a.a = resNstRec.a.a + a.a.a;
		resNstRec.a.b = resNstRec.a.b + a.a.b;
		resNstRec.a.c = resNstRec.a.c + a.a.c;
		resNstRec.b.a = resNstRec.b.a + a.b.a;
		resNstRec.b.b = resNstRec.b.b + a.b.b;
		resNstRec.b.c = resNstRec.b.c + a.b.c;
		resNstRec.c.a = resNstRec.c.a + a.c.a;
		resNstRec.c.b = resNstRec.c.b + a.c.b;
		resNstRec.c.c = resNstRec.c.c + a.c.c;
	}
	add = t.stop();
	res = res + resNstRec.a.a + resNstRec.b.a + resNstRec.c.a;

	t.start();
	for a in arrNstRec {
		resNstRec.a.a = resNstRec.a.a - a.a.a;
		resNstRec.a.b = resNstRec.a.b - a.a.b;
		resNstRec.a.c = resNstRec.a.c - a.a.c;
		resNstRec.b.a = resNstRec.b.a - a.b.a;
		resNstRec.b.b = resNstRec.b.b - a.b.b;
		resNstRec.b.c = resNstRec.b.c - a.b.c;
		resNstRec.c.a = resNstRec.c.a - a.c.a;
		resNstRec.c.b = resNstRec.c.b - a.c.b;
		resNstRec.c.c = resNstRec.c.c - a.c.c;
	}
	sub = t.stop();

	t.start();
	for a in arrNstRec {
		resNstRec.a.a = resNstRec.a.a * a.a.a;
		resNstRec.a.b = resNstRec.a.b * a.a.b;
		resNstRec.a.c = resNstRec.a.c * a.a.c;
		resNstRec.b.a = resNstRec.b.a * a.b.a;
		resNstRec.b.b = resNstRec.b.b * a.b.b;
		resNstRec.b.c = resNstRec.b.c * a.b.c;
		resNstRec.c.a = resNstRec.c.a * a.c.a;
		resNstRec.c.b = resNstRec.c.b * a.c.b;
		resNstRec.c.c = resNstRec.c.c * a.c.c;
	}
	mul = t.stop();

	t.start();
	for a in arrNstRec {
		resNstRec.a.a = resNstRec.a.a / a.a.a;
		resNstRec.a.b = resNstRec.a.b / a.a.b;
		resNstRec.a.c = resNstRec.a.c / a.a.c;
		resNstRec.b.a = resNstRec.b.a / a.b.a;
		resNstRec.b.b = resNstRec.b.b / a.b.b;
		resNstRec.b.c = resNstRec.b.c / a.b.c;
		resNstRec.c.a = resNstRec.c.a / a.c.a;
		resNstRec.c.b = resNstRec.c.b / a.c.b;
		resNstRec.c.c = resNstRec.c.c / a.c.c;
	}
	div = t.stop();
	writeln("nRecordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = res + resNstRec.a.a + resNstRec.b.a + resNstRec.c.a;
}

proc array_with_types_rw() {
	var arrDom1D: domain(1);	// rectangular domain
	var arrInt: [arrDom1D] int;
	var arrReal: [arrDom1D] real;
	var arrTup: [arrDom1D] Tuple;
	var arrRec: [arrDom1D] Record;
	var arrNstTup: [arrDom1D] nstTuple;
	var arrNstRec: [arrDom1D] nstRecord;
	var resInt: int;
	var resReal: real;
	var resTup: Tuple;
	var resRec: Record;
	var resNstTup: nstTuple;
	var resNstRec: nstRecord;

	arrDom1D = [1..n];

	/* 
	   The operation includes both memory read and write,
	   thus the performance analysis should be careful.
	 */
	writeln("Evaluation of Array with Types (Read/Write)");
	writeln("# of ops: ", n, ", time unit: usec");

	// Int Array
	t.start();
	for d in arrInt.domain do arrInt(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) + d; 
	add = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) - d; 
	sub = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) * d; 
	mul = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) / d; 
	div = t.stop();
	res = resInt;
	writeln("intArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Real Array
	t.start();
	for d in arrReal.domain do arrReal(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) + d;
	add = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) - d;
	sub = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) * d;
	mul = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) / d;
	div = t.stop();
	writeln("realArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Tuple Array
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = d;
		arrTup(d)(2) = d;
		arrTup(d)(3) = d;
	}
	asg = t.stop();
	
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = arrTup(d)(1) + d;
		arrTup(d)(2) = arrTup(d)(2) + d;
		arrTup(d)(3) = arrTup(d)(3) + d;
	}
	add = t.stop();
	
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = arrTup(d)(1) - d;
		arrTup(d)(2) = arrTup(d)(2) - d;
		arrTup(d)(3) = arrTup(d)(3) - d;
	}
	sub = t.stop();
	
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = arrTup(d)(1) * d;
		arrTup(d)(2) = arrTup(d)(2) * d;
		arrTup(d)(3) = arrTup(d)(3) * d;
	}
	mul = t.stop();
	
	t.start();
	for d in arrTup.domain {
		arrTup(d)(1) = arrTup(d)(1) / d;
		arrTup(d)(2) = arrTup(d)(2) / d;
		arrTup(d)(3) = arrTup(d)(3) / d;
	}
	div = t.stop();
	writeln("tupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Record Array
	t.start();
	for d in arrRec.domain {
		arrRec(d).a = d;
		arrRec(d).b = d;
		arrRec(d).c = d;
	}
	asg = t.stop();
	
	t.start();
	for d in arrRec.domain {
		arrRec(d).a = arrRec(d).a + d;
		arrRec(d).b = arrRec(d).b + d;
		arrRec(d).c = arrRec(d).c + d;
	}
	add = t.stop();

	t.start();
	for d in arrRec.domain {
		arrRec(d).a = arrRec(d).a - d;
		arrRec(d).b = arrRec(d).b - d;
		arrRec(d).c = arrRec(d).c - d;
	}
	sub = t.stop();

	t.start();
	for d in arrRec.domain {
		arrRec(d).a = arrRec(d).a * d;
		arrRec(d).b = arrRec(d).b * d;
		arrRec(d).c = arrRec(d).c * d;
	}
	mul = t.stop();

	t.start();
	for d in arrRec.domain {
		arrRec(d).a = arrRec(d).a / d;
		arrRec(d).b = arrRec(d).b / d;
		arrRec(d).c = arrRec(d).c / d;
	}
	div = t.stop();
	writeln("recordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Nested Tuple
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = d;
		arrNstTup(d)(1)(2) = d;
		arrNstTup(d)(1)(3) = d;
		arrNstTup(d)(2)(1) = d;
		arrNstTup(d)(2)(2) = d;
		arrNstTup(d)(2)(3) = d;
		arrNstTup(d)(3)(1) = d;
		arrNstTup(d)(3)(2) = d;
		arrNstTup(d)(3)(3) = d;
	}
	asg = t.stop();
	
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = arrNstTup(d)(1)(1) + d;
		arrNstTup(d)(1)(2) = arrNstTup(d)(1)(2) + d;
		arrNstTup(d)(1)(3) = arrNstTup(d)(1)(3) + d;
		arrNstTup(d)(2)(1) = arrNstTup(d)(2)(1) + d;
		arrNstTup(d)(2)(2) = arrNstTup(d)(2)(2) + d;
		arrNstTup(d)(2)(3) = arrNstTup(d)(2)(3) + d;
		arrNstTup(d)(3)(1) = arrNstTup(d)(3)(1) + d;
		arrNstTup(d)(3)(2) = arrNstTup(d)(3)(2) + d;
		arrNstTup(d)(3)(3) = arrNstTup(d)(3)(3) + d;
	}
	add = t.stop();
	
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = arrNstTup(d)(1)(1) - d;
		arrNstTup(d)(1)(2) = arrNstTup(d)(1)(2) - d;
		arrNstTup(d)(1)(3) = arrNstTup(d)(1)(3) - d;
		arrNstTup(d)(2)(1) = arrNstTup(d)(2)(1) - d;
		arrNstTup(d)(2)(2) = arrNstTup(d)(2)(2) - d;
		arrNstTup(d)(2)(3) = arrNstTup(d)(2)(3) - d;
		arrNstTup(d)(3)(1) = arrNstTup(d)(3)(1) - d;
		arrNstTup(d)(3)(2) = arrNstTup(d)(3)(2) - d;
		arrNstTup(d)(3)(3) = arrNstTup(d)(3)(3) - d;
	}
	sub = t.stop();
	
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = arrNstTup(d)(1)(1) * d;
		arrNstTup(d)(1)(2) = arrNstTup(d)(1)(2) * d;
		arrNstTup(d)(1)(3) = arrNstTup(d)(1)(3) * d;
		arrNstTup(d)(2)(1) = arrNstTup(d)(2)(1) * d;
		arrNstTup(d)(2)(2) = arrNstTup(d)(2)(2) * d;
		arrNstTup(d)(2)(3) = arrNstTup(d)(2)(3) * d;
		arrNstTup(d)(3)(1) = arrNstTup(d)(3)(1) * d;
		arrNstTup(d)(3)(2) = arrNstTup(d)(3)(2) * d;
		arrNstTup(d)(3)(3) = arrNstTup(d)(3)(3) * d;
	}
	mul = t.stop();
	
	t.start();
	for d in arrNstTup.domain {
		arrNstTup(d)(1)(1) = arrNstTup(d)(1)(1) / d;
		arrNstTup(d)(1)(2) = arrNstTup(d)(1)(2) / d;
		arrNstTup(d)(1)(3) = arrNstTup(d)(1)(3) / d;
		arrNstTup(d)(2)(1) = arrNstTup(d)(2)(1) / d;
		arrNstTup(d)(2)(2) = arrNstTup(d)(2)(2) / d;
		arrNstTup(d)(2)(3) = arrNstTup(d)(2)(3) / d;
		arrNstTup(d)(3)(1) = arrNstTup(d)(3)(1) / d;
		arrNstTup(d)(3)(2) = arrNstTup(d)(3)(2) / d;
		arrNstTup(d)(3)(3) = arrNstTup(d)(3)(3) / d;
	}
	div = t.stop();
	writeln("nTupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Nested Record
	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = d;
		arrNstRec(d).a.b = d;
		arrNstRec(d).a.c = d;
		arrNstRec(d).b.a = d;
		arrNstRec(d).b.b = d;
		arrNstRec(d).b.c = d;
		arrNstRec(d).c.a = d;
		arrNstRec(d).c.b = d;
		arrNstRec(d).c.c = d;
	}
	asg = t.stop();
	
	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = arrNstRec(d).a.a + d;
		arrNstRec(d).a.b = arrNstRec(d).a.b + d;
		arrNstRec(d).a.c = arrNstRec(d).a.c + d;
		arrNstRec(d).b.a = arrNstRec(d).b.a + d;
		arrNstRec(d).b.b = arrNstRec(d).b.b + d;
		arrNstRec(d).b.c = arrNstRec(d).b.c + d;
		arrNstRec(d).c.a = arrNstRec(d).c.a + d;
		arrNstRec(d).c.b = arrNstRec(d).c.b + d;
		arrNstRec(d).c.c = arrNstRec(d).c.c + d;
	}
	add = t.stop();

	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = arrNstRec(d).a.a - d;
		arrNstRec(d).a.b = arrNstRec(d).a.b - d;
		arrNstRec(d).a.c = arrNstRec(d).a.c - d;
		arrNstRec(d).b.a = arrNstRec(d).b.a - d;
		arrNstRec(d).b.b = arrNstRec(d).b.b - d;
		arrNstRec(d).b.c = arrNstRec(d).b.c - d;
		arrNstRec(d).c.a = arrNstRec(d).c.a - d;
		arrNstRec(d).c.b = arrNstRec(d).c.b - d;
		arrNstRec(d).c.c = arrNstRec(d).c.c - d;
	}
	sub = t.stop();

	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = arrNstRec(d).a.a * d;
		arrNstRec(d).a.b = arrNstRec(d).a.b * d;
		arrNstRec(d).a.c = arrNstRec(d).a.c * d;
		arrNstRec(d).b.a = arrNstRec(d).b.a * d;
		arrNstRec(d).b.b = arrNstRec(d).b.b * d;
		arrNstRec(d).b.c = arrNstRec(d).b.c * d;
		arrNstRec(d).c.a = arrNstRec(d).c.a * d;
		arrNstRec(d).c.b = arrNstRec(d).c.b * d;
		arrNstRec(d).c.c = arrNstRec(d).c.c * d;
	}
	mul = t.stop();

	t.start();
	for d in arrNstRec.domain {
		arrNstRec(d).a.a = arrNstRec(d).a.a / d;
		arrNstRec(d).a.b = arrNstRec(d).a.b / d;
		arrNstRec(d).a.c = arrNstRec(d).a.c / d;
		arrNstRec(d).b.a = arrNstRec(d).b.a / d;
		arrNstRec(d).b.b = arrNstRec(d).b.b / d;
		arrNstRec(d).b.c = arrNstRec(d).b.c / d;
		arrNstRec(d).c.a = arrNstRec(d).c.a / d;
		arrNstRec(d).c.b = arrNstRec(d).c.b / d;
		arrNstRec(d).c.c = arrNstRec(d).c.c / d;
	}
	div = t.stop();
	writeln("nRecordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
}

proc array_with_types_rwo() {
	var arrDom1D: domain(1);
	var arrInt: [arrDom1D] int;
	var arrReal: [arrDom1D] real;
	var arrTup: [arrDom1D] Tuple;
	var arrRec: [arrDom1D] Record;
	var arrNstTup: [arrDom1D] nstTuple;
	var arrNstRec: [arrDom1D] nstRecord;
	var resInt: int;
	var resReal: real;
	var resTup: Tuple;
	var resRec: Record;
	var resNstTup: nstTuple;
	var resNstRec: nstRecord;

	arrDom1D = [1..n];

	/* 
	   The operation includes both memory read and write,
	   thus the performance analysis should be careful.
	 */
	writeln("Evaluation of Array with Types (Read/Write, Overloading)");
	writeln("# of ops: ", n, ", time unit: usec");

	// Int Array
	t.start();
	for d in arrInt.domain do arrInt(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) + d; 
	add = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) - d; 
	sub = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) * d; 
	mul = t.stop();
	
	t.start();
	for d in arrInt.domain do arrInt(d) = arrInt(d) / d; 
	div = t.stop();
	res = resInt;
	writeln("intArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Real Array
	t.start();
	for d in arrReal.domain do arrReal(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) + d;
	add = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) - d;
	sub = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) * d;
	mul = t.stop();
	
	t.start();
	for d in arrReal.domain do arrReal(d) = arrReal(d) / d;
	div = t.stop();
	writeln("realArr\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Tuple Array
	t.start();
	for d in arrTup.domain do arrTup(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrTup.domain do arrTup(d) = arrTup(d) + d;
	add = t.stop();
	
	t.start();
	for d in arrTup.domain do arrTup(d) = arrTup(d) - d;
	sub = t.stop();
	
	t.start();
	for d in arrTup.domain do arrTup(d) = arrTup(d) * d;
	mul = t.stop();
	
	t.start();
	for d in arrTup.domain do arrTup(d) = arrTup(d) / d;
	div = t.stop();
	writeln("tupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	// Record Array
	t.start();
	for d in arrRec.domain do arrRec(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrRec.domain do arrRec(d) = arrRec(d) + d;
	add = t.stop();

	t.start();
	for d in arrRec.domain do arrRec(d) = arrRec(d) - d;
	sub = t.stop();

	t.start();
	for d in arrRec.domain do arrRec(d) = arrRec(d) * d;
	mul = t.stop();

	t.start();
	for d in arrRec.domain do arrRec(d) = arrRec(d) / d;
	div = t.stop();
	writeln("recordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	res = resRec.a;

	// Nested Tuple
	t.start();
	for d in arrNstTup.domain do arrNstTup(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrNstTup.domain do arrNstTup(d) = arrNstTup(d) + d;
	add = t.stop();
	
	t.start();
	for d in arrNstTup.domain do arrNstTup(d) = arrNstTup(d) - d;
	sub = t.stop();
	
	t.start();
	for d in arrNstTup.domain do arrNstTup(d) = arrNstTup(d) * d;
	mul = t.stop();
	
	t.start();
	for d in arrNstTup.domain do arrNstTup(d) = arrNstTup(d) / d;
	div = t.stop();
	writeln("nTupleArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	// Nested Record
	t.start();
	for d in arrNstRec.domain do arrNstRec(d) = d;
	asg = t.stop();
	
	t.start();
	for d in arrNstRec.domain do arrNstRec(d) = arrNstRec(d) + d;
	add = t.stop();

	t.start();
	for d in arrNstRec.domain do arrNstRec(d) = arrNstRec(d) - d;
	sub = t.stop();

	t.start();
	for d in arrNstRec.domain do arrNstRec(d) = arrNstRec(d) * d;
	mul = t.stop();

	t.start();
	for d in arrNstRec.domain do arrNstRec(d) = arrNstRec(d) / d;
	div = t.stop();
	writeln("nRecordArr\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
}
proc task_parallel() {
	var dom: domain(1) = [1..n];
	var arr: [dom] int;
	var tm_for, tm_forall, tm_coforall: real;

	t.start();
	for a in arr do a = a + 1;
	tm_for = t.stop();
	
	t.start();
	forall a in arr do a = a + 2;
	tm_forall = t.stop();
	
//	t.start();
//	coforall a in arr do a = a + 2;
//	tm_coforall = t.stop();
	writeln("taskp\t",tm_for,"\t\t",tm_forall,"\t\t",tm_coforall);
	
	// Reduce
	/*
	t.start();
	resInt = + reduce arrInt;
	add = t.stop();
	
	t.start();
	resInt = * reduce arrInt;
	mul = t.stop();
	
	writeln("intRdc\t\t",add,"\t\t",mul);
	res = res + resInt;
	
	t.start();
	resReal = + reduce arrReal;
	add = t.stop();
	
	t.start();
	resReal = * reduce arrReal;
	mul = t.stop();
	
	writeln("realRdc\t\t",add,"\t\t",mul);
	res = res + resReal;
	*/
}

proc main() {
//  primitive_types();
//	array_with_types_r();
//	array_with_types_rw();
//	array_with_types_rwo();
	parallel_types();
///	task_parallel();
}
