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

/* allpairs2d.chpl */

use common;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const temperature: real = 1.0;
config const initUcellX: int = 20;
config const initUcellY: int = 20;
config const stepAvg: int = 100;
config const stepEquil: int = 0;
config const stepLimit: int = 10000;
config const profLevel: int = 0;
const NDIM: int = 2;

var rCut, velMag, timeNow, uSum, virSum, vvSum: real;
var initUcell: vector2d_i; 
var region, vSum: vector2d;
var nMol, stepCount, moreCycles: int; 
var kinEnergy, totEnergy, pressure: prop;
var molDom: domain(1) = [1..1];	// use domain to reallocate array
var mol: [molDom] mol2d;
var timer: elapsedTimer;

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / sqrt(density) * initUcell;
	nMol = initUcell.prod();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	stepCount = 0;

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
	for ny in [0..initUcell.y-1] {
		for nx in [0..initUcell.x-1] {
			mol(n).r = (nx + 0.5, ny + 0.5) * gap - (0.5 * region);
			n += 1;
		}
	}

	// Initial velocities and accelerations
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand2d();
		vSum += m.rv;
	}
	for m in mol {
		m.rv += (-1.0 / nMol) * vSum;
		m.ra.zero();	// accelerations
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
		m.rv += (0.5 * deltaT) * m.ra;
		m.r += deltaT * m.rv;
	}

	// Apply boundary condition
	for m in mol do
		m.r = vwrap2d(m.r, region);

	// Compute forces
	var dr: vector2d;
	var fcVal, rr, rrCut, rri, rri3: real;

	rrCut = rCut ** 2;
	for m in mol do
		m.ra.zero();

	uSum = 0;
	virSum = 0;

	for d in [1..nMol-1] {
		for d2 in [d+1..nMol] {
			dr = mol(d).r - mol(d2).r;
			dr = vwrap2d(dr, region);
			rr = dr.lensq();
			if rr < rrCut {
				rri = 1.0 / rr;
				rri3 = rri ** 3;
				fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
				mol(d).ra += fcVal * dr;
				mol(d2).ra += (-fcVal) * dr;
				uSum += 4 * rri3 * (rri3 - 1.0) + 1;
				virSum += fcVal * rr;
			}
		}
	}
	
	// Leafrog
	for m in mol do
		m.rv += (0.5 * deltaT) * m.ra;

	// Evaluate thermodynamics properties
	vSum.zero();
	vvSum = 0;
	for m in mol {
		vSum += m.rv;
		vvSum += m.rv.lensq();
	}
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
	pressure.v = density * (vvSum + virSum) / (nMol * NDIM);
		
	// Accumulate thermodynamics properties
	totEnergy.acc();
	kinEnergy.acc();
	pressure.acc();
		
	if stepCount % stepAvg == 0 {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);
		pressure.avg(stepAvg);

		// Print summary
		writeln("\t", stepCount, "\t", timeNow, 
			"\t", (vSum.x + vSum.y) / nMol,
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
	if profLevel >= 1 then writeln("Init: ", timer.stop());

	moreCycles = 1;
	while (moreCycles) {
		if profLevel >= 1 then timer.start();
		step();
		if profLevel >= 1 then
			writeln("Step ", stepCount, ": ", timer.stop());
		if (stepCount >= stepLimit) then moreCycles = 0;
	};
}
