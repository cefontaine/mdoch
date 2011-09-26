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

/* vector.chpl */

/* 
 * Investigate performance of vector manipulations by 
 * using tuple and records.
 */

use Time;

config const arrSize: int = 10000;

type Tuple = (real, real, real);
record Record {
	var x, y, z: real;
}
// Nested types
type nstTuple = (Tuple, Tuple, Tuple);
record nstRecord {
	var x, y, z: Record;
}

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

var arrDom: domain(1) = [1..arrSize];
var arrTup: [arrDom] Tuple;
var arrRec: [arrDom] Record;
var arrNstTup: [arrDom] nstTuple;
var arrNstRec: [arrDom] nstRecord;
var resTup: Tuple;
var resRec: Record;
var resNstTup: nstTuple;
var resNstRec: nstRecord;
var tmpTuple: Tuple;
var tmpRecord: Record;
var t: myTimer;
var res, asg, add, sub, mul, div: real;

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

proc =(a: nstRecord, b: (3*real, 3*real, 3*real)) {
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

proc +(a: nstRecord, b: nstRecord) {
	var r: nstRecord;
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

proc -(a: nstRecord, b: nstRecord) {
	var r: nstRecord;
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

proc *(a: nstRecord, b: nstRecord) {
	var r: nstRecord;
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

proc /(a: nstRecord, b: nstRecord) {
	var r: nstRecord;
	r.x = a.x / b.x;
	r.y = a.y / b.y;
	r.z = a.z / b.z;
	return r;
}

var devnull = new file("basic_chpl.out", FileAccessMode.write);
devnull.open();

writeln("# of ops: ", arrSize, ", time unit: usec");
writeln("\t\tasg\t\tadd\t\tsub\t\tmul\t\tdiv"); 

// Basic double operation
t.start();
for d in arrDom do res = d;
asg = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = d + 1.0;
add = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = d - 2.0;
sub = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = d * 3.0;
mul = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = d / 4.0;
div = t.stop();
devnull.write(res);
writeln("float\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// Array
var arr: [arrDom] real;
t.start();
for d in arrDom do arr[d] = d;
asg = t.stop();
devnull.write(arr(1));

t.start();
for d in arrDom do res = arr(d) + arr(d % arrSize + 1);
add = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = arr(d) - arr(d % arrSize + 1);
sub = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = arr(d) * arr(d % arrSize + 1);
mul = t.stop();
devnull.write(res);

t.start();
for d in arrDom do res = arr(d) / arr(d % arrSize + 1);
div = t.stop();
devnull.write(res);
writeln("array\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

// 1D-array vs.struct
t.start();
for d in arrDom do arrTup(d) = (1.0, 1.0, 1.0);
asg = t.stop();
devnull.write(arrTup(1));

t.start();
for d in arrDom do resTup = arrTup(d) + arrTup(d % arrSize + 1);
add = t.stop();;
devnull.write(resTup);

t.start();
for d in arrDom do resTup = arrTup(d) - arrTup(d % arrSize + 1);
sub = t.stop();
devnull.write(resTup);

t.start();
for d in arrDom do resTup = arrTup(d) * arrTup(d % arrSize + 1);
mul = t.stop();
devnull.write(resTup);

t.start();
for d in arrDom do resTup = arrTup(d) / arrTup(d % arrSize + 1);
div = t.stop();
devnull.write(resTup);
writeln("1D-tup\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

t.start();
for d in arrDom do arrRec(d) = (1.0, 1.0, 1.0);
asg = t.stop(); 
devnull.write(resRec);

t.start();
for d in arrDom do resRec = arrRec(d) + arrRec(d % arrSize + 1);
add = t.stop();
devnull.write(resRec);

t.start();
for d in arrDom do resRec = arrRec(d) - arrRec(d % arrSize + 1);
sub = t.stop();
devnull.write(resRec);

t.start();
for d in arrDom do resRec = arrRec(d) * arrRec(d % arrSize + 1);
mul = t.stop();
devnull.write(resRec);

t.start();
for d in arrDom do resRec = arrRec(d) / arrRec(d % arrSize + 1);
div = t.stop();
devnull.write(resRec);
writeln("1D-rec\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);


// 2D-array vs. struct
t.start();
for d in arrDom do
	arrNstTup(d) = ((1.0, 1.0, 1.0), (2.0, 2.0, 2.0), (3.0, 3.0, 3.0));
asg = t.stop();

t.start();
for d in arrDom do
	resNstTup = arrNstTup(d) + arrNstTup(d % arrSize + 1);
add = t.stop();

t.start();
for d in arrDom do
	resNstTup = arrNstTup(d) - arrNstTup(d % arrSize + 1);
sub = t.stop();

t.start();
for d in arrDom do
	resNstTup = arrNstTup(d) * arrNstTup(d % arrSize + 1);
mul = t.stop();

t.start();
for d in arrDom do
	resNstTup = arrNstTup(d) / arrNstTup(d % arrSize + 1);
div = t.stop();
writeln("2D-tup\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

t.start();
for d in arrDom do
	arrNstRec(d) = ((1.0, 1.0, 1.0), (2.0, 2.0, 2.0), (3.0, 3.0, 3.0));
asg = t.stop();

t.start();
for d in arrDom do
	resNstRec = arrNstRec(d) + arrNstRec(d % arrSize + 1);
add = t.stop();

t.start();
for d in arrDom do
	resNstRec = arrNstRec(d) - arrNstRec(d % arrSize + 1);
sub = t.stop();

t.start();
for d in arrDom do
	resNstRec = arrNstRec(d) * arrNstRec(d % arrSize + 1);
mul = t.stop();

t.start();
for d in arrDom do
	resNstRec = arrNstRec(d) / arrNstRec(d % arrSize + 1);
div = t.stop();
writeln("2D-rec\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

devnull.close();
