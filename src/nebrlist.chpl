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

/* nebrlist.c */

use common;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const initUcellX: int = 5;
config const initUcellY: int = 5;
config const initUcellZ: int = 5;
config const nebrTabFac: int = 8;
config const randSeed: int = 17;
config const rNebrShell: real = 0.4;
config const stepAvg: int = 2000;
config const stepEquil: int = 0;
config const stepInitlzTemp: int = 999999;
config const stepLimit: int = 10000;
config const temperature: real = 1.0;
const NDIM = 3;

var rCut, velMag, timeNow, uSum, virSum, vvSum, dispHi, kinEnInitSum: real;
var region, vSum: vector;
var initUcell, cells: vector_i;
var nMol, stepCount, moreCycles, nebrTabLen, nebrTabMax: int; 
var kinEnergy, totEnergy, pressure: prop;
var nebrNow: bool;
var molDom: domain(1) = [1..1];	// use domain to reallocate array
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..1];
var nebrTab: [nebrTabDom] int;

proc printConfig() {
	writeln(
		"deltaT          ", deltaT, "\n",
		"density         ", density, "\n",
		"initUcell       ", initUcellX, " ",initUcellY," ",initUcellZ,"\n",
		"nebrTabFac      ", nebrTabFac, "\n",
		"randSeed        ", randSeed, "\n",
		"rNebrShell      ", rNebrShell, "\n",
		"stepAvg         ", stepAvg, "\n",
		"stepEquil       ", stepEquil, "\n",
		"stepInitlzTemp  ", stepInitlzTemp, "\n",
		"stepLimit       ", stepLimit, "\n",
		"temperature     ", temperature, "\n",
		"----");
	stdout.flush();
}

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY, initUcellZ);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / cbrt(density)  * initUcell;
	nMol = initUcell.prod();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol) * temperature);
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..cells.prod() + nMol];
	nebrTabDom = [1..2 * nebrTabMax];
	kinEnergy = new prop();
	totEnergy = new prop();
	pressure = new prop();

	initRand(randSeed);
	stepCount = 0;
	var gap: vector = region / initUcell;
	var n: int = 1;
	for (nz, ny, nx) in [0..initUcell.z-1,0..initUcell.y-1,0..initUcell.x-1] {
		mol(n).r = (nx + 0.5, ny + 0.5, nz + 0.5) * gap - (0.5 * region);
		n += 1;
	}
	
	// Initial velocities and accelerations
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand();
		vSum += m.rv;
	}
	for m in mol {
		m.rv -= (1.0 / nMol) * vSum;
		m.ra.zero();
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	pressure.zero();
	kinEnInitSum = 0.0;
	nebrNow = true;
}

proc buildNebrList() {
	var dr, invWid, shift: vector;
	var cc, m1v, m2v: vector_i;
	var rrNebr: real;
	var c, m1, m2: int;
	var vOff = OFFSET_VALS;

	rrNebr = (rCut + rNebrShell) ** 2;
	invWid = cells / region;
	for n in [nMol + 1..nMol + cells.prod()] do cellList(n) = -1; 
	for n in mol.domain {
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, cells) + nMol;
		cellList(n) = cellList(c);
		cellList(c) = n;
	}
	nebrTabLen = 0;
	
	for (m1z, m1y, m1x) in [0..cells.z-1, 0..cells.y-1, 0..cells.x-1] {
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, cells) + nMol;
		for f in iterAscend(1, N_OFFSET) {
			m2v = m1v + vOff(f);
			shift.zero();
			vcellwrap(m2v, cells, shift, region);
			m2 = vlinear(m2v, cells) + nMol;
			for j1 in iterCellList(m1, cellList) {
				for j2 in iterCellList(m2, cellList) {
					if (m1 != m2 || j2 < j1) {
						dr = mol(j1).r - mol(j2).r - shift;
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
	for m in mol {
		m.rv += (0.5 * deltaT) * m.ra;
		m.r += deltaT * m.rv;
	}
	for m in mol do m.r = vwrap(m.r, region);

	if nebrNow {
		nebrNow = false;
		dispHi = 0.0;
		buildNebrList();
	}
}

proc main() {
	printConfig();
	init();
	moreCycles = 1;
	while moreCycles {
		step();
		if stepCount >= stepLimit then moreCycles = 0;
	}
}
