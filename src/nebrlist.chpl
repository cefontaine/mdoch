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
config const initUcellD: int = 0;
config const initUcellX: int = 0;
config const initUcellY: int = 0;
config const initUcellZ: int = 0;
config const nebrTabFac: int = 8;
config const randSeed: int = 17;
config const rNebrShell: real = 0.4;
config const stepAvg: int = 2000;
config const stepEquil: int = 0;
config const stepInitlzTemp: int = 999999;
config const stepLimit: int = 10000;
config const temperature: real = 1.0;
config const profLevel: int = 0;
const NDIM = 3;

var _initUcellX, _initUcellY, _initUcellZ: int;
var rCut, velMag, timeNow, uSum, virSum, vvSum, dispHi, kinEnInitSum: real;
var region, vSum: vector;
var initUcell, cells: vector_i;
var nMol, stepCount, moreCycles, nebrTabLen, nebrTabMax: int; 
var kinEnergy, totEnergy, pressure: prop;
var nebrNow: bool;
var molDom: domain(1);
var mol: [molDom] mol3d;
var cellListDom: domain(1);
var cellList: [cellListDom] int;
var nebrTabDom: domain(1);
var nebrTab: [nebrTabDom] int;
var timer: elapsedTimer;

_initUcellX = 5;
_initUcellY = 5;
_initUcellZ = 5;
if initUcellD > 0  {
	_initUcellX = initUcellD;
	_initUcellY = initUcellD;
	_initUcellZ = initUcellD;
}
if initUcellX > 0 then _initUcellX = initUcellX;
if initUcellY > 0 then _initUcellY = initUcellY;
if initUcellZ > 0 then _initUcellZ = initUcellZ;

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
	initUcell = (_initUcellX, _initUcellY, _initUcellZ);
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
	forall m in mol {
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

	if profLevel == 3 then timer.start();
	for n in iterAscend(nMol + 1, nMol + cells.prod()) do cellList(n) = -1; 
	for n in mol.domain {
		cc.x = ((mol(n).r.x + 0.5 * region.x) * invWid.x):int;
		cc.y = ((mol(n).r.y + 0.5 * region.y) * invWid.y):int;
		cc.z = ((mol(n).r.z + 0.5 * region.z) * invWid.z):int;
		c = (cc.z * cells.y + cc.y) * cells.x + cc.x + 1 + nMol;
//		c = vlinear(cc, cells) + nMol;
		cellList(n) = cellList(c);
		cellList(c) = n;
	}
	if profLevel == 3 then writeln("BuildNebrList:Set: ", timer.stop());
	nebrTabLen = 0;
	
	if profLevel == 3 then timer.start();
	for (m1z, m1y, m1x) in iterAscend3(0,cells.z-1,0,cells.y-1,0,cells.x-1) {
		//m1v.set(m1x, m1y, m1z);
		m1v.x = m1x;
		m1v.y = m1y;
		m1v.z = m1z;
		//m1 = vlinear(m1v, cells) + nMol;
		m1 = (m1v.z * cells.y + m1v.y) * cells.x + m1v.x + 1 + nMol;
		for f in iterAscend(1, N_OFFSET) {
			m2v.x = m1v.x + vOff(f)(1);
			m2v.y = m1v.y + vOff(f)(2);
			m2v.z = m1v.z + vOff(f)(3);
			//shift.zero();
			shift.x = 0;
			shift.y = 0;
			shift.z = 0;
			//vcellwrap(m2v, cells, shift, region);
			if m2v.x >= cells.x { m2v.x = 0; shift.x = region.x; }
			else if m2v.x < 0 { m2v.x = cells.x - 1; shift.x = - region.x; }
			if m2v.y >= cells.y { m2v.y = 0; shift.y = region.y; }
			else if m2v.y < 0 { m2v.y = cells.y - 1; shift.y = - region.y; }
			if m2v.z >= cells.z { m2v.z = 0; shift.z = region.z; }
			else if m2v.z < 0 { m2v.z = cells.z - 1; shift.z = - region.z; }
			//m2 = vlinear(m2v, cells) + nMol;
			m2 = (m2v.z * cells.y + m2v.y) * cells.x + m2v.x + 1 + nMol;
			for (j1, j2) in iterCellList2(m1, m2, cellList) {
				if (m1 != m2 || j2 < j1) {
					dr.x = mol(j1).r.x - mol(j2).r.x - shift.x;
					dr.y = mol(j1).r.y - mol(j2).r.y - shift.y;
					dr.z = mol(j1).r.z - mol(j2).r.z - shift.z;
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
	if profLevel == 3 then writeln("BuildNebrList:Iter: ", timer.stop());
}

proc computeForces() {
	var dr: vector;
	var fcVal, rr, rrCut, rri, rri3, uVal: real;
	var j1, j2: int;

	rrCut = rCut ** 2;
	for m in mol do	m.ra.zero();
	uSum = 0;
	virSum = 0.0;
	
	for n in iterAscend(1, nebrTabLen) {
		j1 = nebrTab(2 * n - 1);
		j2 = nebrTab(2 * n);
		dr = mol(j1).r - mol(j2).r;	
//		dr = vwrap((mol(j1).r - mol(j2).r), region);
		if dr.x >= 0.5 * region.x then dr.x -= region.x;
		else if dr.x < -0.5 * region.x then dr.x += region.x;
		if dr.y >= 0.5 * region.y then dr.y -= region.y;
		else if dr.y < -0.5 * region.y then dr.y += region.y;
		if dr.z >= 0.5 * region.z then dr.z -= region.z;
		else if dr.z < -0.5 * region.z then dr.z += region.z;
		rr = dr.lensq();
		if rr < rrCut {
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
			uVal = 4.0 * rri3 * (rri3 - 1.0) + 1.0;
			mol(j1).ra += fcVal * dr;
			mol(j2).ra -= fcVal * dr;
			uSum += uVal;
			virSum += fcVal * rr;
		}
	}
}

proc step() {
	stepCount += 1;
	timeNow = stepCount * deltaT;
	
	if profLevel == 2 then timer.start();
	for m in mol {
		m.rv += (0.5 * deltaT) * m.ra;
		m.r += deltaT * m.rv;
	}
	if profLevel == 2 then writeln("LeapfrogStep(1): ", timer.stop());

	if profLevel == 2 then timer.start();
//	for m in mol do m.r = vwrap(m.r, region);
	for m in mol {
		if m.r.x >= 0.5 * region.x then m.r.x -= region.x;
		else if m.r.x < -0.5 * region.x then m.r.x += region.x;

		if m.r.y >= 0.5 * region.y then m.r.y -= region.y;
		else if m.r.y < -0.5 * region.y then m.r.y += region.y;
		
		if m.r.z >= 0.5 * region.z then m.r.z -= region.z;
		else if m.r.z < -0.5 * region.z then m.r.z += region.z;
	}
	if profLevel == 2 then writeln("ApplyBoundaryCond: ", timer.stop());
	
	if profLevel == 2 then timer.start();
	if nebrNow {
		nebrNow = false;
		dispHi = 0.0;
		buildNebrList();
	}
	if profLevel == 2 then writeln("BuildNebrList: ", timer.stop());
	
	if profLevel == 2 then timer.start();
	computeForces();
	if profLevel == 2 then writeln("ComputeForces: ", timer.stop());
	
	if profLevel == 2 then timer.start();
	for m in mol do m.rv += (0.5 * deltaT) * m.ra;
	if profLevel == 2 then writeln("LeapfrogStep(2): ", timer.stop());

	if profLevel == 2 then timer.start();
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
	if profLevel == 2 then writeln("Stat: ", timer.stop());
}

proc main() {
	printConfig();
	if profLevel == 1 then timer.start();
	init();
	if profLevel == 1 then writeln("init: ", timer.stop());
	moreCycles = 1;
	while moreCycles {
		step();
		if stepCount >= stepLimit then moreCycles = 0;
	}
}
