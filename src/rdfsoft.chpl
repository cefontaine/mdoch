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

/* rdfsoft.chpl */

use common;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const initUcellX: int = 8;
config const initUcellY: int = 8;
config const initUcellZ: int = 8;
config const nebrTabFac: int = 40;
config const rNebrShell: real = 0.4;
config const limitRdf: int = 100;
config const rangeRdf: real = 4.0;
config const sizeHistRdf: int = 200;
config const stepRdf: int = 50;
config const stepAvg: int = 1000;
config const stepEquil: int = 2000;
config const stepInitlzTemp: int = 200;
config const stepLimit: int = 17000;
config const temperature: real = 1.0;
const NDIM = 3;

var rCut, velMag, timeNow, uSum, vvSum, dispHi, kinEnInitSum: real;
var region, vSum: vector;
var initUcell, cells: vector_i;
var nMol, stepCount, moreCycles, nebrTabLen, nebrTabMax, countRdf: int; 
var kinEnergy, totEnergy: prop;
var nebrNow: bool;
var molDom: domain(1) = [1..1];
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..1];
var nebrTab: [nebrTabDom] int;
var histRdfDom: domain(1) = [1..1];
var histRdf: [histRdfDom] real;

proc printConfig() {
	writeln(
		"deltaT          ", deltaT, "\n",
		"density         ", density, "\n",
		"initUcell       ", initUcellX, " ",initUcellY," ",initUcellZ,"\n",
		"nebrTabFac      ", nebrTabFac, "\n",
		"rNebrShell      ", rNebrShell, "\n",
		"limitRdf        ", limitRdf, "\n",
		"rangeRdf        ", rangeRdf, "\n",
		"stepRdf         ", stepRdf, "\n",
		"sizeHistRdf     ", sizeHistRdf, "\n",
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
	region = 1.0 / cbrt(density / 4.0)  * initUcell;
	nMol = 4 * initUcell.prod();
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol) * temperature);
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..cells.prod() + nMol];
	nebrTabDom = [1..2 * nebrTabMax];
	histRdfDom = [1..sizeHistRdf];
	kinEnergy = new prop();
	totEnergy = new prop();

	stepCount = 0;
	var c: vector;
	var gap: vector = region / initUcell;
	var n: int = 1;
	for (nz, ny, nx) in [0..initUcell.z-1,0..initUcell.y-1,0..initUcell.x-1] {
		c = (nx + 0.25, ny + 0.25, nz + 0.25) * gap - (0.5 * region);
		for j in iterAscend(0, 3) {
			mol(n).r = c;
			if j != 3 {
				if j != 0 then mol(n).r.x += 0.5 * gap.x;
				if j != 1 then mol(n).r.y += 0.5 * gap.y;
				if j != 2 then mol(n).r.z += 0.5 * gap.z;
			}
			n += 1;
		}
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
	kinEnInitSum = 0.0;
	nebrNow = true;
	countRdf = 0;
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
              		if m1 != m2 || j2 < j1 {
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

proc computeForces() {
	var dr: vector;
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
}

proc evalRdf() {
	var dr: vector;
	var deltaR, rr, normFac: real;
	var n: int;

	if countRdf == 0 then
		for n in [1..sizeHistRdf] do histRdf(n) = 0.0;

	deltaR = rangeRdf / sizeHistRdf;
	for j1 in [1..nMol - 1] {
		for j2 in iterAscend(j1 + 1, nMol) {
			dr = vwrap((mol(j1).r - mol(j2).r), region);
			rr = dr.lensq();
			if rr < rangeRdf ** 2 {
				n = (sqrt(rr) / deltaR): int + 1;
				histRdf(n) += 1;
			}
		}
	}
	countRdf += 1;
	if countRdf == limitRdf {
		normFac = region.prod() / (2.0 * PI * (deltaR ** 3) * 
			(nMol ** 2) * countRdf);
		for n in [1..sizeHistRdf] do histRdf(n) *= normFac / ((n - 1.5) ** 2);
		
		writeln("rdf");
		for n in iterAscend(1, sizeHistRdf) do
			writeln((n - 0.5) * rangeRdf / sizeHistRdf, " ", histRdf(n));
		stdout.flush();
		countRdf = 0;
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
	computeForces();
	for m in mol do m.rv += (0.5 * deltaT) * m.ra;
	
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

	if stepCount % stepAvg == 0 {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);

		writeln("\t", stepCount, "\t", timeNow, "\t", vSum.csum() / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2, "\t", kinEnergy.sum,
			"\t", kinEnergy.sum2);
		stdout.flush();

		totEnergy.zero();
		kinEnergy.zero();
	}

	if stepCount >= stepEquil && 
		(stepCount - stepEquil) % stepRdf == 0  then evalRdf();
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
