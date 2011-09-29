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
 * Fast Multipole Method
 */

/* fmm.chpl */

use common;

config const chargeMag: real = 4.0;
config const deltaT: real = 0.005;
config const density: real = 0.8;
config const initUcellX: int = 20;
config const initUcellY: int = 20;
config const initUcellZ: int = 20;
config const maxLevel: int = 3;
config const rNebrShell: real = 0.4;
config const limitRdf: int = 50;
config const rangeRdf: real = 6.0;
config const sizeHistRdf: int = 200;
config const stepAvg: int = 100;
config const stepEquil: int = 2000;
config const stepInitlzTemp: int = 200;
config const stepLimit: int = 8000;
config const stepRdf: int = 20;
config const temperature: real = 1.0;
config const wellSep: int = 1;
config const profLevel: int = 0;
const NDIM: int = 3;

var rCut, timeNow, velMag, kinEnInitSum, dispHi: real;
var initUcell, cells, mpCells: vector_i;
var region, vSum: vector;
var nMol, moreCycles, stepCount, 
	nebrNow, nebrTabFac, nebrTabMax, nebrTabLen: int;
var molDom: domain(1) = [1..1];
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var mpCellDom: domain(2*int);	// associate/irregular domain
var mpCell: [mpCellDom] mp_cell;
var maxCellsEdge, maxOrd: int;
var mpCellListDom: domain(1) = [1..1];
var mpCellList: [mpCellListDom] int;
var histRdfDom, cumRdfDom: domain(2) = [1..1, 1..1];
var histRdf: [histRdfDom] real;
var cumRdf: [cumRdfDom] real;
var kinEnergy, totEnergy: prop;
var timer: elapsedTimer;

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY, initUcellZ);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / (density ** (1.0/3.0)) * initUcell;
	nMol = initUcell.prod();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol) * temperature);
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	maxOrd = MAX_MPEX_ORD;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..(cells.prod() + nMol)];
	
	/* Synthesize irregualr domain
	 * According to specification, removing indices from super-domain is
	 * dangerous, so add up subdomains */
	mpCellDom = [1..maxLevel, 1..1];
	maxCellsEdge = 2;
	for n in [2..maxLevel] {	/* TO CHECK */
		maxCellsEdge *= 2;
		mpCells.set(maxCellsEdge);
		mpCellDom += [n..n, 1..mpCells.prod()];
	}

	mpCellListDom = [1..(nMol + mpCells.prod())];
	histRdfDom = [1..2, 1..sizeHistRdf];
	cumRdfDom = [1..2, 1..sizeHistRdf];

	stepCount = 0;
	
	// Initial coordinates
	var c, gap: vector;
	var n: int;

	gap = region / initUcell;
	n = 1;
	for nz in [0..initUcell.z-1] {
		for ny in [0..initUcell.y-1] {
			for nx in [0..initUcell.x-1] {
				mol(n).r = (nx + 0.5, ny + 0.5, nz + 0.5) * gap
					- (0.5 * region);
				n += 1;
			}
		}
	}

	// Initial velocities, accelerations, and charges
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand();
		vSum += m.rv;
	}
	for m in mol {
		m.rv += (-1.0 / nMol) * vSum;
		m.ra.zero();	// accelerations
		if randR() > 0.5 then m.chg = chargeMag;	// charges
		else m.chg = -chargeMag;
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	nebrNow = 1;
	kinEnInitSum = 0.0;
}

proc buildNebrList() {
	var dr, invWid: vector;
	var cc, m1v: vector_i;
	var rrNebr: real;
	var c: int;

	rrNebr = (rCut + rNebrShell) ** 2;
	invWid = cells / region;
	
	for n in [nMol+1..(cells.prod() + nMol)] do cellList(n) = -1;
	for n in mol.domain {
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, cells) + nMol;
		cellList(n) = cellList(c);
		cellList(c) = n;
	}
	nebrTabLen = 0;
	
	for m1z in [0..cells.z] {
		for m1y in [0..cells.y] {
			for m1x in [0..cells.x] {
				m1v.set(m1x, m1y, m1z);
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

	if nebrNow {
		nebrNow = 0;
		dispHi = 0.0;
		buildNebrList();
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
