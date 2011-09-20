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

/* 
 * Test performance of vector manipulation by using tuple, records, and class
 * vector.chpl
 */

use Time;

const arrSize: int = 10000000;

type Tuple = (real, real, real);
record Record {
	var x, y, z: real;
}
class Class {
	var x, y, z: real;
}

var arrDom: domain(1) = [1..arrSize];
var arrTuple: [arrDom] Tuple;
var arrRecord: [arrDom] Record;
var arrClass: [arrDom] Class;
var resTuple: Tuple;
var resRecord: Record;
var resClass: Class;
var t: Timer;

proc +(a: Record, b: Record) {
	var r: Record;
	r.x = a.x + b.x;
	r.y = a.y + b.y;
	r.z = a.z + b.z;
	return r;
}

proc *(a: Record, b: (real, real, real)) {
	var r: Record;
	r.x = a.x * b(1);
	r.y = a.y * b(2);
	r.z = a.z * b(3);
	return r;
}

proc +(a: Class, b: Class) {
	var r: Class;
	r.x = a.x + b.x;
	r.y = a.y + b.y;
	r.z = a.z + b.z;
	return r;
}

// Main
resClass = new Class();

t.start();
for d in arrDom {
	arrTuple(d) = (1, 1, 1);
}
for a in arrTuple do
	resTuple = resTuple + a * (2.0, 3.0, 4.0);
t.stop();
writeln("Using tuple took ", t.elapsed(TimeUnits.microseconds), " usecs.");

t.start();
for d in arrDom {
	arrRecord(d).x = 1;
	arrRecord(d).y = 1;
	arrRecord(d).z = 1;
}
for a in arrRecord do
	resRecord = resRecord + a * (2.0, 3.0, 4.0);
t.stop();
writeln("Using record took ", t.elapsed(TimeUnits.microseconds), " usecs.");

t.start();
for d in arrDom {
	arrClass(d) = new Class();
	arrClass(d).x = 1;
	arrClass(d).y = 1;
	arrClass(d).z = 1;
}
for a in arrClass {
	resClass.x += a.x;
	resClass.y += a.y;
	resClass.z += a.z;
}
t.stop();
writeln("Using class took ", t.elapsed(TimeUnits.microseconds), " usecs.");
