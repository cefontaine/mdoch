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

const IADD: int =  453806245;
const IMUL: int =  314159269;
const MASK: int =  2147483647;
const SCALE: real = 0.4656612873e-9;
const PI: real = 3.1415926535;

type vector2d = (real, real);
type mol2d = (vector2d, vector2d, vector2d);
type prop = (real, real, real);

var randSeedP: int = 17;

proc vrand2d() {
	var s: real;

	randSeedP = (randSeedP * IMUL + IADD) & MASK;
	s = 2 * PI * randSeedP * SCALE;
	return (cos(s), sin(s));
}

proc vwrap2d(v: vector2d, region: vector2d) {
	var x: real = v(1);
	var y: real = v(2);

	if x >= 0.5 * region(1) then x -= region(1);
	else if x < -0.5 * region(1) then x += region(1);

	if y >= 0.5 * region(2) then y -= region(2);
	else if y < -0.5 * region(2) then y += region(2);

	return (x, y);
}
