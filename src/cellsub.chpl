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

/* cellsub.chpl */

use common;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const initUcellX: int = 5;
config const initUcellY: int = 5;
config const initUcellZ: int = 5;
config const stepAvg: int = 2000;
config const stepEquil: int = 0;
config const stepInitlzTemp: int = 999999;
config const stepLimit: int = 10000;
config const temperature: real = 1.0;
const NDIM = 3;

var rCut, velMag, timeNow, uSum, virSum, vvSum, kinEnInitSum: real;
var region, vSum: vector;
var initUcell, cells: vector_i;
var nMol, stepCount, moreCycles: int; 
var kinEnergy, totEnergy, pressure: prop;
var molDom: domain(1) = [1..1];	// use domain to reallocate array
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;

proc printConfig() {
	writeln(
		"deltaT          ", deltaT, "\n",
		"density         ", density, "\n",
		"initUcell       ", initUcellX, " ",initUcellY," ",initUcellZ,"\n",
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
	cells = 1.0 / rCut * region;

	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..cells.prod() + nMol];
	kinEnergy = new prop();
	totEnergy = new prop();
	pressure = new prop();
	
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
}

proc computeForces () {
	var dr, invWid, shift: vector;
	var cc, m1v, m2v: vector_i;
	var rr, rri, rri3, rrCut, fcVal, uVal: real;
	var c, m1, m2: int;
	var vOff = OFFSET_VALS;
	rrCut = rCut ** 2;
	invWid = cells / region;
	for n in [nMol + 1..nMol + cells.prod()] do cellList(n) = -1;
	for n in mol.domain {
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, cells) + nMol;
		cellList(n) = cellList(c);
		cellList(c) = n;
		mol(n).ra.zero();
	}
	uSum = 0.0;
	virSum = 0.0;
	for (m1x, m1y, m1z) in [0..cells.x-1, 0..cells.y-1, 0..cells.z-1] {
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, cells) + nMol;
		for o in iterAscend(1, N_OFFSET) {
			m2v = m1v + vOff(o);
			shift.zero();
			vcellwrap(m2v, cells, shift, region);
			m2 = vlinear(m2v, cells) + nMol;
			for j1 in iterCellList(m1, cellList) {
				for j2 in iterCellList(m2, cellList) {
					if m1 != m2 || j2 < j1 {
						dr = mol(j1).r - mol(j2).r - shift;
						rr = dr.lensq();
						if (rr < rrCut) {
							rri = 1.0 / rr;
							rri3 = rri ** 3;
							fcVal = 48.0 * rri3 * (rri3 - 0.5) * rri;
							uVal = 4.0 * rri3 * (rri3 - 1.0) + 1.0;
							mol(j1).ra += fcVal * dr;
							mol(j2).ra -= fcVal * dr;
							uSum += uVal;
							virSum += fcVal * rr;
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
	computeForces();
	for m in mol do m.rv += (0.5 * deltaT) * m.ra;
	
	vSum.zero();
	vvSum = 0.0;
	for m in mol {
		vSum += m.rv;
		vvSum += m.rv.lensq();
	}

	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
	pressure.v = density * (vvSum + virSum) / (nMol * NDIM);
	
	var vFac: real;
	if stepCount < stepEquil {
		kinEnInitSum += kinEnergy.v;
		if stepCount % stepInitlzTemp == 0 {
			kinEnInitSum /= stepInitlzTemp;
			vFac = velMag / sqrt(2.0 * kinEnInitSum);
			for m in mol do m.rv *= vFac;
			kinEnInitSum = 0.0;
		}
	}

	totEnergy.acc();
	kinEnergy.acc();
	pressure.acc();

	if stepCount % stepAvg == 0 {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);
		pressure.avg(stepAvg);

		writeln("\t", stepCount, "\t", timeNow, "\t", vSum.csum() / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2, "\t", kinEnergy.sum,
			"\t", kinEnergy.sum2, "\t", pressure.sum, "\t", pressure.sum2);
		stdout.flush();

		totEnergy.zero();
		kinEnergy.zero();
		pressure.zero();
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
