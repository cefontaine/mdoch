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

/* common.chpl */

use Time;

// Constants
const IADD: int =  453806245;
const IMUL: int =  314159269;
const MASK: int =  2147483647;
const SCALE: real = 0.4656612873e-9;
const PI: real = 3.1415926535;
const MAX_MPEX_ORD: int = 2;

// Utilities
proc errExit(s: string) {
	writeln(s);
	stdin.flush();
	exit(0);
}

proc isOdd(a: int) { 
	if a % 2 == 0 then return false;
	else return true;
}

proc isEven(a: int) {
	if a & 1 == 0 then return true;
	else return false;
}

proc max(a:real, b:real) {
	if a > b then return a;
	else return b;
}

proc max(a:int, b:int) {
	if a > b then return a;
	else return b;
}

proc min(a:real, b:real) {
	if a < b then return a;
	else return b;
}

proc min(a:int, b:int) {
	if a < b then return a;
	else return b;
}

var randSeedP: int = 17;

proc initRand(randSeedI: int) {
  if randSeedI != 0 then randSeedP = randSeedI;
  else randSeedP = getCurrentTime(): int;
}

proc randR() {
	randSeedP = (randSeedP * IMUL + IADD) & MASK;
	return (randSeedP * SCALE);
}

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
}

// Iterators
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

iter iterAscend2(min1: int, max1: int, min2:int, max2:int,
	step1: int = 1, step2: int = 1) {
	var i, j: int;
	i = min1;
	while i <= max1 {
		j = min2;
		while j <= max2 {
			yield (i, j);
			j += step2;
		}
		i += step1;
	}
}

iter iterAscend3(min1: int, max1: int, min2:int, max2:int, min3:int,
	max3:int, step1: int = 1, step2: int = 1, step3: int = 1) {
	var i, j, k: int;
	i = min1;
	while i <= max1 {
		j = min2;
		while j <= max2 {
			k = min3;
			while k <= max3 {
				yield (i, j, k);
				k += step3;
			}
			j += step2;
		}
		i += step1;
	}
}

proc vcellwrap(inout v: vector_i, cells: vector_i, inout shift: vector, 
	region: vector) {
	if v.x >= cells.x { v.x = 0; shift.x = region.x; }
	else if v.x < 0 { v.x = cells.x - 1; shift.x = - region.x; }
	if v.y >= cells.y { v.y = 0; shift.y = region.y; }
	else if v.y < 0 { v.y = cells.y - 1; shift.y = - region.y; }
	if v.z >= cells.z { v.z = 0; shift.z = region.z; }
	else if v.z < 0 { v.z = cells.z - 1; shift.z = - region.z; }
}

//////////////////////////////////////
// 3D Vector
//////////////////////////////////////
record vector {
	var x, y, z: real;
	proc set(v: real) {x = v; y = v; z = v;}
	proc set(a: real, b: real, c: real) {x = a; y = b; z = c;}
	proc zero() { x = 0; y = 0; z = 0;}
	proc prod() { return x * y * z; }
	proc len() { return sqrt(x ** 2 + y ** 2 + z ** 2); }
	proc lensq() { return x ** 2 + y ** 2 + z ** 2; }
	proc scale(s: real) { x *= s; y *= s; z *= s; }
	proc csum() { return x + y + z; }
}

record vector_i {
	var x, y, z: int;
	proc set(v: int) {x = v; y = v; z = v;}
	proc set(a: int, b: int, c: int) {x = a; y = b; z = c;}
	proc zero() { x = 0; y = 0; z = 0;}
	proc prod() { return x * y * z; }
	proc len() { return sqrt(x ** 2 + y ** 2 + z ** 2); }
	proc lensq() { return x ** 2 + y ** 2 + z ** 2; }
	proc scale(s: int) { x *= s; y *= s; z *= s; }
	proc csum() { return x + y + z; }
	proc ll_x(ws: int) { return (x & ~1) - 2 * ws; }
	proc ll_y(ws: int) { return (y & ~1) - 2 * ws; }
	proc ll_z(ws: int) { return (z & ~1) - 2 * ws; }
	proc hl_x(ws: int) { return (x & ~1) + 2 * ws + 1; }
	proc hl_y(ws: int) { return (y & ~1) + 2 * ws + 1; }
	proc hl_z(ws: int) { return (z & ~1) + 2 * ws + 1; }
}

proc =(v: vector, t: (real, real, real)) {
	var r: vector;
	r.x = t(1);
	r.y = t(2);
	r.z = t(3);
	return r;
}

proc =(v: vector, t: (int, int, int)) {
	var r: vector;
	r.x = t(1);
	r.y = t(2);
	r.z = t(3);
	return r;
}

proc =(v: vector_i, t: (int, int, int)) {
	var r: vector_i;
	r.x = t(1);
	r.y = t(2);
	r.z = t(3);
	return r;
}

proc =(v1: vector_i, v2: vector) {
	var r: vector_i;
	r.x = v2.x: int;
	r.y = v2.y: int;
	r.z = v2.z: int;
	return r;
}

proc =(v1: vector, v2: vector_i) {
	var r: vector;
	r.x = v2.x;
	r.y = v2.y;
	r.z = v2.z;
	return r;
}

proc +(v: vector_i, s: real) {
	var r: vector;
	r.x = v.x + s;
	r.y = v.y + s;
	r.z = v.z + s;
	return r;
}

proc +(v: vector, s: real) {
	var r: vector;
	r.x = v.x + s;
	r.y = v.y + s;
	r.z = v.z + s;
	return r;
}

proc +(v1: vector, v2: vector) {
	var r: vector;
	r.x = v1.x + v2.x;
	r.y = v1.y + v2.y;
	r.z = v1.z + v2.z;
	return r;
}

proc +(v: vector_i, t: (int, int, int)) {
	var r: vector_i;
	r.x = v.x + t(1);
	r.y = v.y + t(2);
	r.z = v.z + t(3); 
	return r;
}

proc -(v1: vector, v2: vector) {
	var r: vector;
	r.x = v1.x - v2.x;
	r.y = v1.y - v2.y;
	r.z = v1.z - v2.z;
	return r;
}

proc -(v1: vector_i, v2: vector_i) {
	var r: vector_i;
	r.x = v1.x - v2.x;
	r.y = v1.y - v2.y;
	r.z = v1.z - v2.z;
	return r;
}

proc *(s: real, v: vector) {
	var r: vector;
	r.x = s * v.x;
	r.y = s * v.y;
	r.z = s * v.z;
	return r;
}

proc *(v: vector, s: real) {
	var r: vector;
	r.x = s * v.x;
	r.y = s * v.y;
	r.z = s * v.z;
	return r;
}

proc *(s: real, v: vector_i) {
	var r: vector;
	r.x = s * v.x;
	r.y = s * v.y;
	r.z = s * v.z;
	return r;
}

proc *(v: vector_i, s: real) {
	var r: vector;
	r.x = s * v.x;
	r.y = s * v.y;
	r.z = s * v.z;
	return r;
}

proc *(s: (real, real, real), v: vector) {
	var r: vector;
	r.x = s(1) * v.x;
	r.y = s(2) * v.y;
	r.z = s(3) * v.z;
	return r;
}

proc *(v1: vector, v2: vector) {
	var r: vector;
	r.x = v1.x * v2.x;
	r.y = v1.y * v2.y;
	r.z = v1.z * v2.z;
	return r;
}

proc *(v1: vector_i, v2: vector_i) {
	var r: vector_i;
	r.x = v1.x * v2.x;
	r.y = v1.y * v2.y;
	r.z = v1.z * v2.z;
	return r;
}

proc *(v1: vector_i, v2: vector) {
	var r: vector;
	r.x = v1.x * v2.x;
	r.y = v1.y * v2.y;
	r.z = v1.z * v2.z;
	return r;
}

proc *(v1: vector, v2: vector_i) {
	var r: vector;
	r.x = v1.x * v2.x;
	r.y = v1.y * v2.y;
	r.z = v1.z * v2.z;
	return r;
}

proc /(v1: vector, v2: vector_i) {
	var r: vector;
	r.x = v1.x / v2.x;
	r.y = v1.y / v2.y;
	r.z = v1.z / v2.z;
	return r;
}

proc /(v1: vector_i, v2: vector) {
	var r: vector;
	r.x = v1.x / v2.x;
	r.y = v1.y / v2.y;
	r.z = v1.z / v2.z;
	return r;
}

proc /(v1: vector, v2: vector) {
	var r: vector;
	r.x = v1.x / v2.x;
	r.y = v1.y / v2.y;
	r.z = v1.z / v2.z;
	return r;
}

proc vdot(v1: vector, v2: vector) {
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

// Calculate index of 3D array by using 1D implementaion
// Remember array starts from 1, thus plus 1
proc vlinear(v1: vector, v2: vector) {
	return (v1.z * v2.y + v1.y) * v2.x + v1.x + 1;
}

proc vlinear(v1: vector, v2: vector_i) {
	return (v1.z * v2.y + v1.y) * v2.x + v1.x + 1;
}

proc vlinear(v1: vector_i, v2: vector) {
	return (v1.z * v2.y + v1.y) * v2.x + v1.x + 1;
}

proc vlinear(v1: vector_i, v2: vector_i) {
	return (v1.z * v2.y + v1.y) * v2.x + v1.x + 1;
}

proc vrand() {
	var r: vector;
	var s, x, y: real;

	s = 2.0;
	while s > 1 {
		x = 2.0 * randR() - 1.0;
		y = 2.0 * randR() - 1.0;
		s = x ** 2 + y ** 2;
	}
	r.z = 1.0 - 2.0 * s;
	s = 2.0 * sqrt(1.0 - s);
	r.x = s * x;
	r.y = s * y;
	return r;
}

proc vwrap(v: vector, region: vector) {
	var r: vector = v;
	
	if r.x >= 0.5 * region.x then r.x -= region.x;
	else if r.x < -0.5 * region.x then r.x += region.x;

	if r.y >= 0.5 * region.y then r.y -= region.y;
	else if r.y < -0.5 * region.y then r.y += region.y;
	
	if r.z >= 0.5 * region.z then r.z -= region.z;
	else if r.z < -0.5 * region.z then r.z += region.z;

	return r;
}

//////////////////////////////////////
// Molecular Types
//////////////////////////////////////
const OFFSET_VALS = ((0,0,0), (1,0,0), (1,1,0), (0,1,0), (-1,1,0), 
    (0,0,1), (1,0,1), (1,1,1), (0,1,1), (-1,1,1), (-1,0,1), 
    (-1,-1,1), (0,-1,1), (1,-1,1));
const N_OFFSET: int = 14;

const OFFSET_VALS_ALL = ((-1,-1,-1), (0,-1,-1), (1,-1,-1), (-1,0,-1), 
	(0,0,-1), (1,0,-1), (-1,1,-1), (0,1,-1), (1,1,-1), (-1,-1,0), 
	(0,-1,0), (1,-1,0), (-1,0,0), (0,0,0), (1,0,0), (-1,1,0), (0,1,0), 
	(1,1,0), (-1,-1,1), (0,-1,1), (1,-1,1), (-1,0,1), (0,0,1), (1,0,1), 
	(-1,1,1), (0,1,1), (1,1,1));
const N_OFFSET_ALL: int = 27;

record mol3d {
	var r, rv, ra: vector;
}

record nebr {
	var n1, n2: int;
	var uVal: real;
	proc zero() { n1 = 0; n2 = 0; uVal = 0; }
	proc set(a: int, b: int) { n1 = a; n2 = b; }
}

record prop {
	var v, sum, sum2: real;
	proc zero() { sum = 0; sum2 = 0; }
	proc acc() { sum += v; sum2 += v ** 2; }
	proc avg(n: real) { 
		sum /= n; 
		sum2 = sqrt(max(sum2 / n - sum ** 2, 0));
	}
}

record mp_terms {
	// size = MAX_MPEX_ORD * (MAX_MPEX_ORD + 1) / 2 + MAX_MPEX_ORD + 1;
	var _c: 6*real;
	var _s: 6*real;
	proc c(i: int) { return _c(i); }
	proc s(i: int) { return _s(i); }
	proc c(i: int, j: int) { return _c(i * (i + 1) / 2 + j + 1); }
	proc s(i: int, j: int) { return _s(i * (i + 1) / 2 + j + 1); }
	proc set_c (v: real, i: int, j: int) { _c(i * (i + 1) / 2 + j + 1) = v; }
	proc set_s (v: real, i: int, j: int) { _s(i * (i + 1) / 2 + j + 1) = v; }
	proc add_c (v: real, i: int, j: int) { _c(i * (i + 1) / 2 + j + 1) += v; }
	proc add_s (v: real, i: int, j: int) { _s(i * (i + 1) / 2 + j + 1) += v; }
	proc sub_c (v: real, i: int, j: int) { _c(i * (i + 1) / 2 + j + 1) -= v; }
	proc sub_s (v: real, i:	int, j: int) { _s(i * (i + 1) / 2 + j + 1) -= v; }
}

record mp_cell {
	var le, me: mp_terms;
	var occ: int;
}

iter iterCellList(n: int, cellList: [] int) {
	var i = cellList(n);
	while i >= 1 {
		yield i;
		i = cellList(i);
	}
}

iter iterCellList2(n: int, n2: int, cellList: [] int) {
	var i = cellList(n);
	var j: int;
	while i >= 1 {
		j = cellList(n2);
		while j >= 1 {
			yield (i, j);
			j = cellList(j);
		}
		i = cellList(i);
	}
}

// Debug utilities
proc debugPrintMol(mol: [] mol3d) {
	for m in mol do
		writeln("r=(", m.r.x, ", ", m.r.y, ", ", m.r.z, ")",
				", rv=(", m.rv.x, ", ", m.rv.y, ", ", m.rv.z, ")", 
				", ra=(", m.ra.x, ", ", m.ra.y, ", ", m.ra.z, ")");
}
