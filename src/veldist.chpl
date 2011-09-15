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

/* veldist.chpl */

use common;

config const deltaT: real = 0.001;
config const density: real = 0.8;
config const temperature: real = 1.0;
config const initUcellX: int = 50;
config const initUcellY: int = 50;
config const limitVel: int = 4;
config const nebrTabFac: int = 4;
config const randSeed: int = 17;
config const rangeVel: real = 3.0;
config const rNebrShell: real = 0.4;
config const sizeHistVel: int = 50;
config const stepAvg: int = 100;
config const stepEquil: int = 0;
config const stepLimit: int = 10000;
config const stepVel: int = 5;
const NDIM: int = 2;
const OFFSET_VALS: [1..5] vector2d_i;
OFFSET_VALS(1) = (0, 0);
OFFSET_VALS(2) = (1, 0);
OFFSET_VALS(3) = (1, 1);
OFFSET_VALS(4) = (0, 1);
OFFSET_VALS(5) = (-1, 1);

var rCut, velMag, timeNow, uSum, virSum, vvSum, dispHi, hFunction: real;
var region, vSum: vector2d;
var initUcell, cells: vector2d_i;
var nMol, stepCount, moreCycles, nebrTabLen, nebrTabMax, countVel: int; 
var kinEnergy, totEnergy, pressure: Prop;
var nebrNow: bool;
var molDom: domain(1) = [1..2];	// use domain to reallocate array
var mol: [molDom] mol2d;
var cellListDom: domain(1) = [1..2];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..2];
var nebrTab: [nebrTabDom] int;
var histVelDom: domain(1) = [1..2];
var histVel: [histVelDom] real;

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / sqrt(density) * initUcell; 
	nMol = initUcell.dot();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	stepCount = 0;
	moreCycles = 1;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..cells.dot() + nMol];
	nebrTabDom = [1..2 * nebrTabMax];
	histVelDom = [1..sizeHistVel];
	
	kinEnergy = new Prop();
	totEnergy = new Prop();
	pressure = new Prop();
	
	initRand(randSeed);

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
	
	totEnergy.setZero();
	kinEnergy.setZero();
	pressure.setZero();
	nebrNow = true;
	countVel = 0;
}

proc buildNebrList() {
	var dr, invWid, rs, shift: vector2d;
	var cc, m1v, m2v: vector2d_i;
	var vOff: [1..OFFSET_VALS.rank] vector2d_i = OFFSET_VALS;
	var rrNebr: real;
	var c, j1, j2, m1, m1x, m1y, m2, offset: int;

	rrNebr = (rCut + rNebrShell) ** 2;
	invWid = cells / region;
	for i in [nMol+1..cellList.rank] do
		cellList(i) = -1;
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
	
	if nebrNow {
		nebrNow = false;
		dispHi = 0;
	}

	// Compute forces
	var dr: vector2d;
	var fcVal, rr, rrCut, rri, rri3: real;
	var i, j, n: int;

	rrCut = rCut ** 2;
	for m in mol do
		m.ra.zero();

	uSum = 0;
	virSum = 0;
	
	for d in mol.domain do {
		for d2 in mol.domain do {
			if d2 > d then {
				dr = mol(d).r - mol(d2).r;
				dr = vwrap2d(dr, region);
				rr = dr.lsqr();
				if rr < rrCut then {
					rri = 1.0 / rr;
					rri3 = rri ** 3;
					fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
					mol(d).ra += (fcVal, fcVal) * dr;
					mol(d2).ra += (-fcVal, -fcVal) * dr;
					uSum += 4 * rri3 * (rri3 - 1.0) + 1;
					virSum += fcVal * rr;
				}
			}
		}
	}

	// Leafrog
	for m in mol do
		m.rv += (0.5 * deltaT) * m.ra;

	// Evaluate themodynamics properties
	var vvMax: real;

	vSum.zero();
	vvSum = 0;
	for m in mol {
		vSum += m.rv;
		vvSum += m.rv.lsqr();
	}
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
	pressure.v = density * (vvSum + virSum) / (nMol * NDIM);
		
	// Accumulate themodynamics properties
	totEnergy.acc();
	kinEnergy.acc();
	pressure.acc();
		
	if stepCount % stepAvg == 0 then {
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
		
		totEnergy.setZero();
		kinEnergy.setZero();
		pressure.setZero();
	}
}

proc main() {
	init();
	while (moreCycles) {
		step();
		if (stepCount >= stepLimit) then
			moreCycles = 0;
	};
};
