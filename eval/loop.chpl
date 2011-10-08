/****************************************************************************
 * Copyright (C) 2011  Nan Dun <dun@logos.ic.i.u-tokyo.ac.jp>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * This program can be distributed under the terms of the GNU GPL.
 * See the file COPYING.
 ***************************************************************************/

/* loop.chpl */

/* 
 * Investigation of performance of various loops
 */

use Time;

config const count: int = 1000000;

record myTimer {
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
}

var t: myTimer;
var i, j, k, I, J, K: int;
var e, res: real;

writeln("# of loops: ", count, ", time unit: usec");

// 1D loop
I = count;
writeln("1D Loop: ", I, "x1");
t.start();
for i in [1..I] do res += 1;
e = t.stop();
writeln("for: ", e);

res = 0;
t.start();
i = 1;
while i <= I { res += 1; i += 1; }
e = t.stop();
writeln("while: ", e);

// 2D loop
I = sqrt(count): int;
J = I;
writeln("\n2D Loop: ", I, "x", J);
res = 0;
t.start();
for i in [1..I] {
	for j in [1..J] {
		res += 1;
	}
}
e = t.stop();
writeln("for-for: ", e);

res = 0;
t.start();
for (i, j) in [1..I, 1..J] do
		res += 1;
e = t.stop();
writeln("for,for : ", e);

res = 0;
t.start();
for i in [1..I] {
	j = 1;
	while j <= J {
		res += 1;
		j += 1;
	}
}
e = t.stop();
writeln("for-while: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	for j in [1..J] do res += 1; 
	i += 1; 
}
e = t.stop();
writeln("while-for: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	j = 1;
	while j <= J {
		res += 1; 
		j += 1;
	}
	i += 1; 
}
e = t.stop();
writeln("while-while: ", e);

// 3D loop
I = cbrt(count): int;
J = I;
K = I;
writeln("\n3D Loop: ", I, "x", J, "x", K);
res = 0;
t.start();
for i in [1..I] {
	for j in [1..J] {
		for k in [1..K] do
			res += 1;
	}
}
e = t.stop();
writeln("for-for-for: ", e);

res = 0;
t.start();
for (i, j, k) in [1..I, 1..J, 1..K] do
			res += 1;
e = t.stop();
writeln("for,for,for: ", e);

res = 0;
t.start();
for i in [1..I] {
	for j in [1..J] {
		k = 1;
		while k <= K {
			res += 1;
			k += 1;
		}
	}
}
e = t.stop();
writeln("for-for-while: ", e);

res = 0;
t.start();
for (i, j) in [1..I, 1..J] {
	k = 1;
	while k <= K {
		res += 1;
		k += 1;
	}
}
e = t.stop();
writeln("for,for-while: ", e);

res = 0;
t.start();
for i in [1..I] {
	j = 1;
	while j <= J {
		for k in [1..K] do
			res += 1;
		j += 1;
	}
}
e = t.stop();
writeln("for-while-for: ", e);

res = 0;
t.start();
for i in [1..I] {
	j = 1;
	while j <= J {
		k = 1;
		while k <= K {
			res += 1;
			k += 1;
		}
		j += 1;
	}
}
e = t.stop();
writeln("for-while-while: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	for j in [1..J] {
		for k in [1..K] do
			res += 1;
	}
	i += 1; 
}
e = t.stop();
writeln("while-for-for: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	for (j, k) in [1..J, 1..K] do
			res += 1;
	i += 1; 
}
e = t.stop();
writeln("while-for,for: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	for j in [1..J] {
		k = 1;
		while k <= K {
			res += 1;
			k += 1;
		}
	}
	i += 1; 
}
e = t.stop();
writeln("while-for-while: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	j = 1;
	while j <= J {
		for k in [1..K] do
			res += 1;
		j += 1;
	}
	i += 1; 
}
e = t.stop();
writeln("while-while-for: ", e);

res = 0;
t.start();
i = 1;
while i <= I {
	j = 1;
	while j <= J {
		k = 1;
		while k <= K {
			res += 1; 
			k += 1;
		}
		j += 1;
	}
	i += 1; 
}
e = t.stop();
writeln("while-while-while: ", e);
