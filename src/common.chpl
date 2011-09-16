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

// Utilities
proc max(a:real, b:real) {
	if a > b then return a;
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

// 2D-Vector
record vector2d {
	var x, y: real;
	proc zero() { x = 0; y = 0; }
	proc prod() { return x * y; }
	proc lensq() { return x ** 2 + y ** 2; }
}

proc =(v: vector2d, t: (real, real)) {
	var r: vector2d;
	r.x = t(1);
	r.y = t(2);
	return r;
}

proc =(v: vector2d, t: (int, int)) {
	var r: vector2d;
	r.x = t(1);
	r.y = t(2);
	return r;
}

proc +(v1: vector2d, v2: vector2d) {
	var s: vector2d;
	s.x = v1.x + v2.x;
	s.y = v1.y + v2.y;
	return s;
}

proc +(a: real, v: vector2d) {
	var s: vector2d;
	s.x = a + v.x;
	s.y = a + v.y;
	return s;
}

proc -(v1: vector2d, v2: vector2d) {
	var s: vector2d;
	s.x = v1.x - v2.x;
	s.y = v1.y - v2.y;
	return s;
}

proc *(a: real, v: vector2d) {
	var s: vector2d;
	s.x = a * v.x;
	s.y = a * v.y;
	return s;
}

proc *(a: (real, real), v: vector2d) {
	var r: vector2d;
	r.x = a(1) * v.x;
	r.y = a(2) * v.y;
	return r;
}

proc /(v1: vector2d, v2: vector2d) {
	var s: vector2d;
	s.x = v1.x / v2.x;
	s.y = v1.y / v2.y;
	return s;
}

record vector2d_i {
	var x, y: int;
	proc prod() { return x * y; }
	proc lensq() { return x ** 2 + y ** 2; }
}

proc =(v: vector2d_i, t: (int, int)) {
	var r: vector2d_i;
	r.x = t(1);
	r.y = t(2);
	return r;
}

proc =(v1: vector2d_i, v2: vector2d) {
	var r: vector2d_i;
	r.x = v2.x: int;
	r.y = v2.y: int;
	return r;
}

proc *(s: real, v: vector2d_i) {
	var r: vector2d;
	r.x = s * v.x;
	r.y = s * v.y;
	return r;
}

proc /(v1: vector2d, v2: vector2d_i) {
	var r: vector2d;
	r.x = v1.x / v2.x;
	r.y = v1.y / v2.y;
	return r;
}

proc vrand2d() {
	var r: vector2d;
	var s: real;

	s = 2 * PI * randR();
	r.x = cos(s);
	r.y = sin(s);
	return r;
}

proc vwrap2d(v: vector2d, region: vector2d) {
	var r: vector2d = v;

	if r.x >= 0.5 * region.x then r.x -= region.x;
	else if r.x < -0.5 * region.x then r.x += region.x;

	if r.y >= 0.5 * region.y then r.y -= region.y;
	else if r.y < -0.5 * region.y then r.y += region.y;

	return r;
}

//////////////////////////////////////
// 3D Vector
//////////////////////////////////////
record vector {
	var x, y, z: real;
	proc zero() { x = 0; y = 0; z = 0;}
	proc prod() { return x * y * z; }
	proc lensq() { return x ** 2 + y ** 2 + z ** 2; }
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

proc vrand() {
	var r: vector;
	var s, x, y: real;

	s = 2;
	while s > 1 {
		x = 2 * randR() - 1;
		y = 2 * randR() - 1;
		s = x ** 2 + y ** 2;
	}
	r.z = 1 - 2 * s;
	s = 2 * sqrt(1 - s);
	r.x = s * x;
	r.y = s * y;
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
record mol2d {
	var r, rv, ra: vector2d;
}

record mol3d {
	var r, rv, ra: vector;
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
