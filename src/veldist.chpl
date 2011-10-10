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
config const profLevel: int = 0;
const NDIM: int = 2;

var rCut, velMag, timeNow, uSum, virSum, vvSum, dispHi, hFunction: real;
var region, vSum: vector2d;
var initUcell, cells: vector2d_i;
var nMol, stepCount, moreCycles, nebrTabLen, nebrTabMax, countVel: int; 
var kinEnergy, totEnergy: prop;
var nebrNow: bool;
var molDom: domain(1) = [1..1];	// use domain to reallocate array
var mol: [molDom] mol2d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..1];
var nebrTab: [nebrTabDom] int;
var histVelDom: domain(1) = [1..1];
var histVel: [histVelDom] real;
var timer: elapsedTimer;

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / sqrt(density) * initUcell; 
	nMol = initUcell.prod();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	stepCount = 0;
	moreCycles = 1;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..cells.prod() + nMol];
	nebrTabDom = [1..2 * nebrTabMax];
	histVelDom = [1..sizeHistVel];
	
	kinEnergy = new prop();
	totEnergy = new prop();
	
	initRand(randSeed);

	// Initial coordinates
	var gap: vector2d;
	var n: int;
	
	gap = region / initUcell;
	n = 1;
	for (ny, nx) in [0..initUcell.y-1, 0..initUcell.x-1] {
		mol(n).r = (nx + 0.5, ny + 0.5) * gap - (0.5 * region);
		n += 1;
	}

	// Initial velocities and accelerations
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand2d();
		vSum += m.rv;
	}
	for m in mol {
		m.rv -= (1.0 / nMol) * vSum;
		m.ra.zero();	// accelerations
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	nebrNow = true;
	countVel = 0;
}

iter iterCellList(n: int) {
	var i = cellList(n);
	while i >= 1 {
		yield i;
		i = cellList(i);
	}
}

proc buildNebrList() {
	var dr, invWid, rs, shift: vector2d;
	var cc, m1v, m2v: vector2d_i;
	var vOff = OFFSET_VALS_2D;
	var rrNebr: real;
	var c, m1, m2, offset: int;

	rrNebr = (rCut + rNebrShell) ** 2;
	invWid = cells / region;
	for i in [nMol + 1..nMol + cells.prod()] do cellList(i) = -1;
	for n in mol.domain {
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, cells) + nMol;
		cellList(n) = cellList(c);
		cellList(c) = n;
	}
	nebrTabLen = 0;
	for (m1y, m1x) in [0..cells.y - 1, 0..cells.x - 1] {
		m1v.set(m1x, m1y);
		m1 = vlinear(m1v, cells) + nMol;
		for o in [1..N_OFFSET_2D] {
			m2v = m1v + vOff(o);
			shift.zero();
			vcellwrap(m2v, cells, shift, region);
			m2 = vlinear(m2v, cells) + nMol;
			for j1 in iterCellList(m1) {
				for j2 in iterCellList(m2) {
					if (m1 != m2 || j2 < j1) {
						dr = mol[j1].r - mol[j2].r - shift;
						if dr.lensq() < rrNebr {
							if nebrTabLen >= nebrTabMax then
								errExit("Too many neighbours");
							nebrTab(2 * nebrTabLen + 1) = j1;
							nebrTab(2 * nebrTabLen + 2) = j2;
							nebrTabLen += 1;
						}
					}
				}
			}
		}
	}
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
		m.r = vwrap(m.r, region);
	
	if nebrNow {
		nebrNow = false;
		dispHi = 0;
		buildNebrList();
	}

	// Compute forces
	var dr: vector2d;
	var fcVal, rr, rrCut, rri, rri3, uVal: real;
	var j1, j2: int;

	rrCut = rCut ** 2;
	for m in mol do	m.ra.zero();
	uSum = 0;
	
	for n in [1..nebrTabLen] {
		j1 = nebrTab(2 * n - 1);
		j2 = nebrTab(2 * n);
		dr = vwrap((mol(j1).r - mol(j2).r), region);
		rr = dr.lensq();
		if rr < rrCut {
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
			uVal = 4.0 * rri3 * (rri3 - 1.0) + 1.0;
			mol(j1).ra += fcVal * dr;
			mol(j2).ra -= fcVal * dr;
			uSum += uVal;
		}
	}
	debugPrintMol2D(mol);

	// Leafrog
	for m in mol do m.rv += (0.5 * deltaT) * m.ra;

	// Evaluate themodynamics properties
	var vv, vvMax: real;

	vSum.zero();
	vvSum = 0.0;
	vvMax = 0.0;
	for m in mol {
		vSum += m.rv;
		vv = m.rv.lensq();
		vvSum += vv;
		vvMax = max(vvMax, vv);
	}
	dispHi += sqrt(vvMax) * deltaT;
	if dispHi > 0.5 * rNebrShell then nebrNow = true;
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
		
	// Accumulate themodynamics properties
	totEnergy.acc();
	kinEnergy.acc();
	
	if stepCount >= stepEquil && (stepCount - stepEquil) % stepVel == 0 {
		var deltaV, histSum: real;
		if countVel == 0 {
			for j in [1..sizeHistVel] do histVel(j) = 0.0;
		}
		deltaV = rangeVel / sizeHistVel;
		for m in mol do
			histVel(min((m.rv.len() / deltaV): int, sizeHistVel)) += 1;
		countVel += 1;
		if countVel == limitVel {
			histSum = 0;
			for j in [1..sizeHistVel] do histSum += histVel(j);
			for j in [1..sizeHistVel] do histVel(j) /= histSum;
			hFunction = 0;
			for j in [1..sizeHistVel] {
				if histVel(j) > 0.0 then
					hFunction += histVel(j) * log(histVel(j));
			writeln("vdist ", timeNow);
			for n in [1..sizeHistVel] do
				writeln((n - 0.5) * rangeVel / sizeHistVel, " ", histVel(n));
			writeln("hfun: ", timeNow, " ", hFunction);
			stdout.flush();
			countVel = 0;
			}
		}
	}
	if stepCount % stepAvg == 0 then {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);

		// Print summary
		writeln("\t", stepCount, "\t", timeNow, 
			"\t", (vSum.x + vSum.y) / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2,
			"\t", kinEnergy.sum, "\t", kinEnergy.sum2);
		stdout.flush();
		
		totEnergy.zero();
		kinEnergy.zero();
	}
}

proc main() {
	init();
	moreCycles = 1;
	while moreCycles {
		step();
		if stepCount >= stepLimit then moreCycles = 0;
	}
}
