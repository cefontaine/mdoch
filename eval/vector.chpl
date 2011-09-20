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

config const arrSize: int = 10000;

type Tuple = (real, real, real);
record Record {
	var x, y, z: real;
}

// Nested types
type molTuple = (Tuple, Tuple, Tuple);
record molRecord {
	var r, rv, ra: Record;
}

var arrDom: domain(1) = [1..arrSize];
var arrTuple: [arrDom] Tuple;
var arrRecord: [arrDom] Record;
var arrMolTuple: [arrDom] molTuple;
var arrMolRecord: [arrDom] molRecord;
var resTuple: Tuple;
var resRecord: Record;
var tmpTuple: Tuple;
var tmpRecord: Record;
var t: Timer;
var e_tuple, e_record: real;	// elapsed time

proc =(a: Record, b: (real, real, real)) {
	a.x = b(1);
	a.y = b(2);
	a.z = b(3);
}

proc =(a: Record, b: (int, int, int)) {
	a.x = b(1);
	a.y = b(2);
	a.z = b(3);
}

proc +(a: Record, b: Record) {
	var r: Record;
	r.x = a.x + b.x;
	r.y = a.y + b.y;
	r.z = a.z + b.z;
	return r;
}

proc -(a: Record, b: Record) {
	var r: Record;
	r.x = a.x - b.x;
	r.y = a.y - b.y;
	r.z = a.z - b.z;
	return r;
}


proc *(a: (real, real, real), b: Record) {
	var r: Record;
	r.x = a(1) * b.x;
	r.y = a(2) * b.y;
	r.z = a(3) * b.z;
	return r;
}

proc *(a: Record, b: (real, real, real)) {
	var r: Record;
	r.x = a.x * b(1);
	r.y = a.y * b(2);
	r.z = a.z * b(3);
	return r;
}

proc *(a: Record, b: Record) {
	var r: Record;
	r.x = a.x * b.x;
	r.y = a.y * b.y;
	r.z = a.z * b.z;
	return r;
}

proc /(a: Record, b: Record) {
	var r: Record;
	r.x = a.x / b.x;
	r.y = a.y / b.y;
	r.z = a.z / b.z;
	return r;
}

writeln("============== 1D Types ================");
// Assignment
t.clear();
t.start();
for d in arrDom do arrTuple(d) = (1.0, 1.0, 1.0);
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);
t.clear();
t.start();
for d in arrDom do arrRecord(d) = (1.0, 1.0, 1.0);
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Assignment elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Addition
tmpTuple = (2.0, 2.0, 2.0);
t.clear();
t.start();
for d in arrDom do arrTuple(d) += tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (2.0, 2.0, 2.0);
t.clear();
t.start();
for d in arrDom do arrRecord(d) += tmpRecord;
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Addition elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Multiplication
tmpTuple = (3.0, 3.0, 3.0);
t.clear();
t.start();
for d in arrDom do arrTuple(d) *= tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (3.0, 3.0, 3.0);
t.clear();
t.start();
for d in arrDom do arrRecord(d) *= tmpRecord;
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Multiplication elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Division
tmpTuple = (4.0, 4.0, 4.0);
t.clear();
t.start();
for d in arrDom do arrTuple(d) /= tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (4.0, 4.0, 4.0);
t.clear();
t.start();
for d in arrDom do arrRecord(d) /= tmpRecord;
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Division elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Operations on nested types
writeln("============== 2D Types ================");
stdout.flush();
// Assignment
t.clear();
t.start();
for d in arrDom {
	arrMolTuple(d)(1) = (1.0, 1.0, 1.0);
	arrMolTuple(d)(2) = (1.0, 1.0, 1.0);
	arrMolTuple(d)(3) = (1.0, 1.0, 1.0);
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

t.clear();
t.start();
for d in arrDom {
	arrMolRecord(d).r = (1.0, 1.0, 1.0);
	arrMolRecord(d).rv = (1.0, 1.0, 1.0);
	arrMolRecord(d).ra = (1.0, 1.0, 1.0);
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Assignment elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Addition
tmpTuple = (2.0, 2.0, 2.0);
t.clear();
t.start();
for d in arrDom { 
	arrMolTuple(d)(1) += tmpTuple;
	arrMolTuple(d)(2) += tmpTuple;
	arrMolTuple(d)(3) += tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (2.0, 2.0, 2.0);
t.clear();
t.start();
for d in arrDom {
	arrMolRecord(d).r += tmpRecord;
	arrMolRecord(d).rv += tmpRecord;
	arrMolRecord(d).ra += tmpRecord;
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Addition elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Multiplication
tmpTuple = (3.0, 3.0, 3.0);
t.clear();
t.start();
for d in arrDom {
	arrMolTuple(d)(1) *= tmpTuple;
	arrMolTuple(d)(2) *= tmpTuple;
	arrMolTuple(d)(3) *= tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (3.0, 3.0, 3.0);
t.clear();
t.start();
for d in arrDom {
	arrMolRecord(d).r *= tmpRecord;
	arrMolRecord(d).rv *= tmpRecord;
	arrMolRecord(d).ra *= tmpRecord;
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Multiplication elapsed: tuple=", e_tuple, ", record=", e_record);

// Division
tmpTuple = (4.0, 4.0, 4.0);
t.clear();
t.start();
for d in arrDom {
	arrMolTuple(d)(1) /= tmpTuple;
	arrMolTuple(d)(2) /= tmpTuple;
	arrMolTuple(d)(3) /= tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (4.0, 4.0, 4.0);

t.clear();
t.start();
for d in arrDom {
	arrMolRecord(d).r /= tmpRecord;
	arrMolRecord(d).rv /= tmpRecord;
	arrMolRecord(d).ra /= tmpRecord;
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Division elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Complex calculation
t.clear();
t.start();
for d in arrDom {
	tmpTuple = (d, d, d);
	arrMolTuple(d)(1) += arrMolTuple((d+1) % arrSize)(1) * tmpTuple;
	arrMolTuple(d)(2) += arrMolTuple((d+1) % arrSize)(2) * tmpTuple;
	arrMolTuple(d)(3) += arrMolTuple((d+1) % arrSize)(3) * tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

t.clear();
t.start();
for d in arrDom {
	tmpRecord = (d, d, d);
	arrMolRecord(d).r += arrMolRecord(d % arrSize + 1).r * tmpRecord;
	arrMolRecord(d).rv += arrMolRecord(d % arrSize + 1).rv * tmpRecord;
	arrMolRecord(d).ra += arrMolRecord(d % arrSize + 1).ra * tmpRecord;
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Complex calc elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();


// Nested types in function
writeln("========= 2D Types in Function =========");
stdout.flush();

proc complexCals() {
	var tmpTuple, tmpRecord: (real, real, real);
	var coTuple: (real, real, real);
	var coRecord: Record;
	
	t.clear();
	t.start();
	for d in arrDom {
		tmpTuple = (d, d, d);
		coTuple = (arrMolTuple((d+1) % arrSize + 1)(1) +
				   arrMolTuple((d+1) % arrSize + 1)(2) +
				   arrMolTuple((d+1) % arrSize + 1)(3)) * tmpTuple;
		arrMolTuple(d)(1) += arrMolTuple(d % arrSize + 1)(1) * coTuple;
		arrMolTuple(d)(2) += arrMolTuple(d % arrSize + 1)(2) * coTuple;
		arrMolTuple(d)(3) += arrMolTuple(d % arrSize + 1)(3) * coTuple;
	}
	t.stop();
	e_tuple = t.elapsed(TimeUnits.microseconds);
	
	t.clear();
	t.start();
	for d in arrDom {
		tmpRecord = (d, d, d);
		coRecord = (arrMolRecord((d+1) % arrSize + 1).r +
		            arrMolRecord((d+1) % arrSize + 1).rv +
					arrMolRecord((d+1) % arrSize + 1).ra) * tmpRecord;
		arrMolRecord(d).r += arrMolRecord(d % arrSize + 1).r * coRecord;
		arrMolRecord(d).rv += arrMolRecord(d % arrSize + 1).rv * coRecord;
		arrMolRecord(d).ra += arrMolRecord(d % arrSize + 1).ra * coRecord;
	}
	t.stop();
	e_record = t.elapsed(TimeUnits.microseconds);

	writeln("Calc in function: tuple=", e_tuple, ", record=", e_record);
	stdout.flush();
}

complexCals();

proc ljCals() {
	var drTuple: (real, real, real);
	var drRecord: Record;
	var fcVal, rr, rrCut, rri, rri3, uSum, virSum: real;

	t.clear();
	t.start();
	for d in [1..arrSize-1] {
		for d2 in [d+1..arrSize] {
			drTuple = arrMolTuple(d)(1) - arrMolTuple(d2)(1);
			rr = drTuple(1) ** 2 + drTuple(2) ** 2 + drTuple(3) ** 2;
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
			arrMolTuple(d)(2) += (fcVal, fcVal, fcVal) * drTuple;
			arrMolTuple(d2)(2) += (-fcVal, -fcVal, -fcVal) * drTuple;
			uSum = 4 * rri3 * (rri3 - 1.0) + 1;
			virSum += fcVal * rr;
		}
	}
	t.stop();
	e_tuple = t.elapsed(TimeUnits.microseconds);
	
	t.clear();
	t.start();
	for d in [1..arrSize-1] {
		for d2 in [d+1..arrSize] {
			drRecord = arrMolRecord(d).r - arrMolRecord(d2).r;
			rr = drRecord.x ** 2 + drRecord.y ** 2 + drRecord.z ** 2;
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
			arrMolRecord(d).ra += (fcVal, fcVal, fcVal) * drRecord;
			arrMolRecord(d2).ra += (-fcVal, -fcVal, -fcVal) * drRecord;
			uSum = 4 * rri3 * (rri3 - 1.0) + 1;
			virSum += fcVal * rr;
		}
	}
	t.stop();
	e_record = t.elapsed(TimeUnits.microseconds);
	
	writeln("LJ in function: tuple=", e_tuple, ", record=", e_record);
	stdout.flush();
}

ljCals();
