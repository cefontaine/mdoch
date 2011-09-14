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

// 2D-Vector
record vector2d {
	var x, y: real;
	
	proc zero() { x = 0; y = 0; }
	
	proc set(a: real, b: real) { x = a; y = b; }
	
	proc dot() { return x * y; }
	
	proc lsqr() { return x ** 2 + y ** 2; }
}

proc =(v: vector2d, t: (real, real)) {
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
	var s: vector2d;
	s.x = a(1) * v.x;
	s.y = a(2) * v.y;
	return s;
}

proc /(v1: vector2d, v2: vector2d) {
	var s: vector2d;
	s.x = v1.x / v2.x;
	s.y = v1.y / v2.y;
	return s;
}

record mol2d {
	var r, rv, ra: vector2d;
}

var randSeedP: int = 17;

proc vrand2d() {
	var r: vector2d;
	var s: real;

	randSeedP = (randSeedP * IMUL + IADD) & MASK;
	s = 2 * PI * randSeedP * SCALE;
	r.x = cos(s);
	r.y = sin(s);
	return r;
}

proc vwrap2d(v: vector2d, region: vector2d) {
	var s: vector2d = v;

	if s.x >= 0.5 * region.x then s.x -= region.x;
	else if s.x < -0.5 * region.x then s.x += region.x;

	if s.y >= 0.5 * region.y then s.y -= region.y;
	else if s.y < -0.5 * region.y then s.y += region.y;

	return s;
}

class Prop {	// Thermodynamic properties
	var v, sum, sum2: real;
	
	proc setZero() { sum = 0; sum2 = 0; }
	
	proc acc() { sum += v; sum2 += v ** 2; }
	
	proc avg(n: real) { 
		sum /= n; 
		sum2 = sqrt(max(sum2 / n - sum ** 2, 0));
	}
}
