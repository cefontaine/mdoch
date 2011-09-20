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

const arrSize: int = 100000;

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
t.start();
for d in arrDom do arrTuple(d) = (1.0, 1.0, 1.0);
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);
t.start();
for d in arrDom do arrRecord(d) = (1.0, 1.0, 1.0);
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Assignment elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Addition
tmpTuple = (2.0, 2.0, 2.0);
t.start();
for d in arrDom do arrTuple(d) += tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (2.0, 2.0, 2.0);
t.start();
for d in arrDom do arrRecord(d) += tmpRecord;
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Addition elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Multiplication
tmpTuple = (3.0, 3.0, 3.0);
t.start();
for d in arrDom do arrTuple(d) *= tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (3.0, 3.0, 3.0);
t.start();
for d in arrDom do arrRecord(d) *= tmpRecord;
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);
writeln("Multiplication elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

// Division
tmpTuple = (4.0, 4.0, 4.0);
t.start();
for d in arrDom do arrTuple(d) /= tmpTuple;
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (4.0, 4.0, 4.0);
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
t.start();
for d in arrDom {
	arrMolTuple(d)(1) = (1.0, 1.0, 1.0);
	arrMolTuple(d)(2) = (1.0, 1.0, 1.0);
	arrMolTuple(d)(3) = (1.0, 1.0, 1.0);
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

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
t.start();
for d in arrDom { 
	arrMolTuple(d)(1) += tmpTuple;
	arrMolTuple(d)(2) += tmpTuple;
	arrMolTuple(d)(3) += tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (2.0, 2.0, 2.0);
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
t.start();
for d in arrDom {
	arrMolTuple(d)(1) *= tmpTuple;
	arrMolTuple(d)(2) *= tmpTuple;
	arrMolTuple(d)(3) *= tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (3.0, 3.0, 3.0);
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
t.start();
for d in arrDom {
	arrMolTuple(d)(1) /= tmpTuple;
	arrMolTuple(d)(2) /= tmpTuple;
	arrMolTuple(d)(3) /= tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (4.0, 4.0, 4.0);
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
tmpTuple = (5.0, 5.0, 5.0);
t.start();
for d in arrDom {
	arrMolTuple(d)(1) += arrMolTuple((d+1) % arrSize)(1) * tmpTuple;
	arrMolTuple(d)(2) += arrMolTuple((d+1) % arrSize)(2) * tmpTuple;
	arrMolTuple(d)(3) += arrMolTuple((d+1) % arrSize)(3) * tmpTuple;
}
t.stop();
e_tuple = t.elapsed(TimeUnits.microseconds);

tmpRecord = (5.0, 5.0, 5.0);
t.start();
for d in arrDom {
	arrMolRecord(d).r += arrMolRecord(d % arrSize + 1).r * tmpRecord;
	arrMolRecord(d).rv += arrMolRecord(d % arrSize + 1).rv * tmpRecord;
	arrMolRecord(d).ra += arrMolRecord(d % arrSize + 1).ra * tmpRecord;
}
t.stop();
e_record = t.elapsed(TimeUnits.microseconds);

writeln("Complex calc elapsed: tuple=", e_tuple, ", record=", e_record);
stdout.flush();

