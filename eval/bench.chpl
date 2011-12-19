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

/* 
 * Evaluation of primitive types: integer, float
 */

config const opCnt: int = 10000;

writeln("Evaluation of Primitive Types");
writeln("# of ops: ", opCnt, ", time unit: usec");
var t: elapsedTimer;
var resInt: int;
var resReal, add, sub, mul, div: real;

// Integer
t.start();
for i in iterAscend(1, opCnt) do resInt = resInt + i;
add = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resInt = resInt - i;
sub = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resInt = resInt * i;
mul = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resInt = resInt / i;
div = t.stop();
writeln("int\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Float
t.start();
for i in iterAscend(1, opCnt) do resReal = resReal + i;
add = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resReal = resReal - i;
sub = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resReal = resReal * i;
mul = t.stop();

t.start();
for i in iterAscend(1, opCnt) do resReal = resReal / i;
div = t.stop();
writeln("real\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

/* 
 * Evaluation of structured types: integer, float, imaginary, complex
 */
writeln("Evaluation of Structured Types");
writeln("# of ops: ", opCnt, ", time unit: usec");
