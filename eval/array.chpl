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

/* array.chpl */

/* 
 * Investigation of performance of rectangular/irregular arrays
 */

use Time;

config const arrSize: int = 1000000;

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
var aloc, asg, add, sub, mul, div: real;
var res: real;

var rctDom1D: domain(1) = [1..1];	// rectangular domain
var rctArr1D: [rctDom1D] real;
var irrDom1D: domain(int);			// irregular domain
var irrArr1D: [irrDom1D] real;
var dim2d, dim3d: int;
dim2d = sqrt(arrSize): int;
dim3d = cbrt(arrSize): int;

writeln("# of ops: ", arrSize, ", 2D array: ", dim2d, "x", dim2d, 
	", 3D array: ", dim3d, "x", dim3d, "x", dim3d, ", time unit: usec");
writeln("\t\taloc\t\tasg\t\tadd\t\tsub\t\tmul\t\tdiv"); 

// 1D array
t.start();
rctDom1D = [1..arrSize];
aloc = t.stop();
t.start();
for d in rctDom1D do rctArr1D(d) = d;
asg = t.stop();
t.start();
for d in rctDom1D do res = rctArr1D(d) + rctArr1D(d % arrSize + 1);
add = t.stop();
t.start();
for d in rctDom1D do res = rctArr1D(d) - rctArr1D(d % arrSize + 1);
sub = t.stop();
t.start();
for d in rctDom1D do res = rctArr1D(d) * rctArr1D(d % arrSize + 1);
mul = t.stop();
t.start();
for d in rctDom1D do res = rctArr1D(d) / rctArr1D(d % arrSize + 1);
div = t.stop();
writeln("1D-rct\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);

t.start();
irrDom1D = [1..arrSize];
aloc = t.stop();
t.start();
for d in irrDom1D do rctArr1D(d) = d;
asg = t.stop();
t.start();
for d in irrDom1D do res = rctArr1D(d) + rctArr1D(d % arrSize + 1);
add = t.stop();
t.start();
for d in irrDom1D do res = rctArr1D(d) - rctArr1D(d % arrSize + 1);
sub = t.stop();
t.start();
for d in irrDom1D do res = rctArr1D(d) * rctArr1D(d % arrSize + 1);
mul = t.stop();
t.start();
for d in irrDom1D do res = rctArr1D(d) / rctArr1D(d % arrSize + 1);
div = t.stop();
writeln("1D-irr\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);

// 2D array
var rctDom2D: domain(2) = [1..1, 1..1];	// rectangular domain
var rctArr2D: [rctDom2D] real;
var irrDom2D: domain(2*int);			// irregular domain
var irrArr2D: [irrDom2D] real;

t.start();
rctDom2D = [1..dim2d, 1..dim2d];
aloc = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do rctArr2D(i, j) = i + j;
asg = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = rctArr2D(i, j) + rctArr2D(i % dim2d + 1, j % dim2d + 1);
add = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = rctArr2D(i, j) - rctArr2D(i % dim2d + 1, j % dim2d + 1);
sub = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = rctArr2D(i, j) * rctArr2D(i % dim2d + 1, j % dim2d + 1);
mul = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = rctArr2D(i, j) / rctArr2D(i % dim2d + 1, j % dim2d + 1);
div = t.stop();
writeln("2D-rct\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);

t.start();
irrDom2D = [1..dim2d, 1..dim2d];
aloc = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do irrArr2D((i, j)) = i + j;
asg = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = irrArr2D((i, j)) + irrArr2D((i % dim2d + 1, j % dim2d + 1));
add = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = irrArr2D((i, j)) - irrArr2D((i % dim2d + 1, j % dim2d + 1));
sub = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = irrArr2D((i, j)) * irrArr2D((i % dim2d + 1, j % dim2d + 1));
mul = t.stop();
t.start();
for (i, j) in [1..dim2d, 1..dim2d] do 
	res = irrArr2D((i, j)) / irrArr2D((i % dim2d + 1, j % dim2d + 1));
div = t.stop();
writeln("2D-irr\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);

// 3D array
var rctDom3D: domain(3) = [1..1, 1..1, 1..1];	// rectangular domain
var rctArr3D: [rctDom3D] real;
var irrDom3D: domain(3*int);					// irregular domain
var irrArr3D: [irrDom3D] real;

t.start();
rctDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
aloc = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do 
	rctArr3D(i, j, k) = i + j + k;
asg = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do 
	res = rctArr3D(i, j, k) + rctArr3D(i%dim3d+1, j%dim3d+1, k%dim3d+1);
add = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do 
	res = rctArr3D(i, j, k) - rctArr3D(i%dim3d+1, j%dim3d+1, k%dim3d+1);
sub = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do 
	res = rctArr3D(i, j, k) * rctArr3D(i%dim3d+1, j%dim3d+1, k%dim3d+1);
mul = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do 
	res = rctArr3D(i, j, k) / rctArr3D(i%dim3d+1, j%dim3d+1, k%dim3d+1);
div = t.stop();
writeln("3D-rct\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);

t.start();
irrDom3D = [1..dim3d, 1..dim3d, 1..dim3d];
aloc = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do
	irrArr3D((i, j, k)) = i + j + k;
asg = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do
	res = irrArr3D((i,j,k)) + irrArr3D((i%dim3d+1, j%dim3d+1, k%dim3d+1));
add = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do
	res = irrArr3D((i,j,k)) - irrArr3D((i%dim3d+1, j%dim3d+1, k%dim3d+1));
sub = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do
	res = irrArr3D((i,j,k)) * irrArr3D((i%dim3d+1, j%dim3d+1, k%dim3d+1));
mul = t.stop();
t.start();
for (i, j, k) in [1..dim3d, 1..dim3d, 1..dim3d] do
	res = irrArr3D((i,j,k)) / irrArr3D((i%dim3d+1, j%dim3d+1, k%dim3d+1));
div = t.stop();
writeln("3D-irr\t\t",aloc,"\t\t",asg,"\t\t",add,"\t\t",sub,
		"\t\t",mul,"\t\t",div);
