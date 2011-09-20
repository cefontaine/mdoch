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

/* allpairs2d.chpl 
 * For performance comparison using tuple as vector
 */

use Time;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const temperature: real = 1.0;
config const initUcellX: int = 20;
config const initUcellY: int = 20;
config const stepAvg: int = 100;
config const stepEquil: int = 0;
config const stepLimit: int = 10000;
config const profLevel: int = 0;

const IADD: int =  453806245;
const IMUL: int =  314159269;
const MASK: int =  2147483647;
const SCALE: real = 0.4656612873e-9;
const PI: real = 3.1415926535;

const NDIM: int = 2;
var randSeedP: int = 17;
var timer: Timer;
var e: real;

type vector2d_i = (int, int);
type vector2d = (real, real);
type mol2d = (vector2d, vector2d, vector2d);
record prop {
	var v, sum, sum2: real;
	proc zero() { sum = 0; sum2 = 0; }
	proc acc() { sum += v; sum2 += v ** 2; }
	proc avg(n: real) { 
		sum /= n; 
		sum2 = sqrt(max(sum2 / n - sum ** 2, 0));
	}
}
proc randR() {
	randSeedP = (randSeedP * IMUL + IADD) & MASK;
	return (randSeedP * SCALE);
}
proc vrand2d() {
	var r: vector2d;
	var s: real;

	s = 2 * PI * randR();
	r(1) = cos(s);
	r(2) = sin(s);
	return r;
}

proc vwrap2d(v: vector2d, region: vector2d) {
	var r: vector2d = v;

	if r(1) >= 0.5 * region(1) then r(1) -= region(1);
	else if r(1) < -0.5 * region(1) then r(1) += region(1);

	if r(2) >= 0.5 * region(2) then r(2) -= region(2);
	else if r(2) < -0.5 * region(2) then r(2) += region(2);

	return r;
}

var rCut, velMag, timeNow, uSum, virSum, vvSum: real;
var initUcell: vector2d_i; 
var region, vSum: vector2d;
var nMol, stepCount, moreCycles: int; 
var kinEnergy, totEnergy, pressure: prop;
var molDom: domain(1) = [1..1];	// use domain to reallocate array
var mol: [molDom] mol2d;

// Operator overriding
proc *(a: real, b: vector2d_i) {
	var r: vector2d;
	r(1) = a * b(1);
	r(2) = a * b(2);
	return r;
}

// Operator overriding
proc *(a: real, b: vector2d) {
	var r: vector2d;
	r(1) = a * b(1);
	r(2) = a * b(2);
	return r;
}

// Major routines
proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / sqrt(density) * initUcell;
	nMol = initUcell(1) * initUcell(2);
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	stepCount = 0;
	moreCycles = 1;

	// Allocate storage
	molDom = [1..nMol];
	kinEnergy = new prop();
	totEnergy = new prop();
	pressure = new prop();

	// Initial coordinates
	var c, gap: vector2d;
	var n: int;
	
	gap = region / initUcell;
	n = 1;
	for ny in [0..initUcell(2)-1] {
		for nx in [0..initUcell(1)-1] {
			mol(n)(1) = (nx + 0.5, ny + 0.5) * gap - (0.5 * region);
			n += 1;
		}
	}

	// Initial velocities and accelerations
	vSum(1) = 0;
	vSum(2) = 0;
	for m in mol {
		m(2) = velMag * vrand2d();
		vSum += m(2);
	}
	for m in mol {
		m(2) += (-1.0 / nMol) * vSum;
		m(3)(1) = 0;	// accelerations
		m(3)(2) = 0;
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	pressure.zero();
}

proc step() {
	stepCount += 1;
	timeNow = stepCount * deltaT;
	
	// Leapfrog
	for m in mol {
		m(2) += (0.5 * deltaT) * m(3);
		m(1) += deltaT * m(2);
	}
	
	// Apply boundary condition
	for m in mol do
		m(1) = vwrap2d(m(1), region);

	// Compute forces
	var dr: vector2d;
	var fcVal, rr, rrCut, rri, rri3: real;
	var i, j, n: int;

	rrCut = rCut ** 2;
	for m in mol {
		m(3)(1) = 0;
		m(3)(2) = 0;
	}

	uSum = 0;
	virSum = 0;
	
	for d in [1..nMol-1] do {
		for d2 in [d+1..nMol] do {
			dr = mol(d)(1) - mol(d2)(1);
			dr = vwrap2d(dr, region);
			rr = dr(1) ** 2 + dr(2) ** 2;
			if rr < rrCut then {
				rri = 1.0 / rr;
				rri3 = rri ** 3;
				fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
				mol(d)(3) += (fcVal, fcVal) * dr;
				mol(d2)(3) += (-fcVal, -fcVal) * dr;
				uSum += 4 * rri3 * (rri3 - 1.0) + 1;
				virSum += fcVal * rr;
			}
		}
	}
	
	// Leafrog
	for m in mol do
		m(2) += (0.5 * deltaT) * m(3);

	// Evaluate themodynamics properties
	var vvMax: real;

	vSum(1) = 0;
	vSum(2) = 0;
	vvSum = 0;
	for m in mol {
		vSum += m(2);
		vvSum += m(2)(1) ** 2 + m(2)(2) ** 2;
	}
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
	pressure.v = density * (vvSum + virSum) / (nMol * NDIM);
		
	// Accumulate themodynamics properties
	totEnergy.acc();
	kinEnergy.acc();
	pressure.acc();
		
	if stepCount % stepAvg == 0 {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);
		pressure.avg(stepAvg);

		// Print summary
		writeln("\t", stepCount, "\t", timeNow, 
			"\t", (vSum(1) + vSum(2)) / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2,
			"\t", kinEnergy.sum, "\t", kinEnergy.sum2,
			"\t", pressure.sum, "\t", pressure.sum2);
		stdout.flush();
		
		totEnergy.zero();
		kinEnergy.zero();
		pressure.zero();
	}
}

proc main() {
	if profLevel >= 1 then timer.start();
	init();
	if profLevel >= 1 {
		timer.stop();
		writeln("Init: ", timer.elapsed(TimeUnits.microseconds));
	}
	
	while (moreCycles) {
		if profLevel >= 1 then timer.start();
		step();
		if profLevel >= 1 {
			timer.stop();
			writeln("Step ", stepCount, ": ",
				timer.elapsed(TimeUnits.microseconds));
		}
		if (stepCount >= stepLimit) then
			moreCycles = 0;
	};
};
