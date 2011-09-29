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

var rCut, timeNow, velMag, kinEnInitSum, dispHi, uSum, vvSum: real;
var initUcell, cells, mpCells: vector_i;
var region, vSum, cellWid: vector;
var nMol, moreCycles, stepCount, countRdf,
	nebrNow, nebrTabFac, nebrTabMax, nebrTabLen,
	curCellsEdge, curLevel: int;
var molDom: domain(1) = [1..1];
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..1];
var nebrTab: [nebrTabDom] int;
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
	nebrTabDom = [1..2 * nebrTabMax];
	
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

iter cellIdx(m: int): int {
	var i: int;

	i = cellList[m];
	writeln("iter: m=", m, " i=", i);
	if i >= 0 {
		yield cellList(i);
	}
	return;
}

proc buildNebrList() {
	var dr, invWid: vector;
	var cc, m1v, m2v: vector_i;
	var rrNebr: real;
	var c, m1, m2, j1, j2: int;
	var vOff = OFFSET_VALS;

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
				m1 = vlinear(m1v, cells) + nMol;
				for f in [1..N_OFFSET] {
					m2v = m1v + vOff(f);
					if m2v.x < 0 || m2v.x >= cells.x || m2v.y < 0 ||
					   m2v.y >= cells.y || m2v.z >= cells.z then continue;
					m2 = vlinear(m2v, cells) + nMol;
					j1 = cellList[m1];
					while j1 >= 0 {
						j2 = cellList[m2];
						while j2 >= 0 {
							if (m1 != m2 || j2 < j1) then
								dr = mol(j1).r - mol(j2).r;
							if dr.lensq() < rrNebr {
								if nebrTabLen >= nebrTabMax then
									errExit("Too many neighbours");
								nebrTab(2 * nebrTabLen) = j1;
								nebrTab(2 * nebrTabLen + 1) = j2;
								nebrTabLen += 1;
							}
							j2 = cellList[j2];
						}
						j1 = cellList[j1];
					}
				}
			}
		}
	}
}

proc computeForces() {
	var dr: vector;
	var rrCut, rr, rri, rri3, fcVal, uVal: real;
	var j1, j2: int;

	rrCut = rCut ** 2;
	for m in mol do m.ra.zero();
	uSum = 0.0;
	for n in [1..nebrTabLen] {
		j1 = nebrTab[2 * n];
		j2 = nebrTab[2 * n + 1];
		dr = mol(j1).r - mol(j2).r;
		rr = dr.lensq();
		if rr < rrCut {
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48.0 * rri3 * (rri3 - 0.5) * rri;
			uVal = 4.0 * rri3 * (rri3 - 1.0) + 1.0;
			mol(j1).ra += fcVal * dr;
			mol(j2).ra += (-fcVal) * dr;
			uSum += uVal;
		}
	}
}

proc evalMpL (inout le: mp_terms, inout v: vector, maxOrd: int) {
	var rr, a, a1, a2: real;
	var k: int;

	rr = v.lensq();
	le.set_c(1.0, 0, 0);
	le.set_s(0.0, 0, 0);
	for j in [1..maxOrd+1] {
		k = j;
		a = - 1.0 / (2 * k);
		le.set_c(a * (v.x * le.c(j - 1, k - 1) - v.y * le.s(j - 1, k - 1)), 
			j, k);
		le.set_s(a * (v.y * le.c(j - 1, k - 1) + v.x * le.s(j - 1, k - 1)), 
			j, k);
		k = j - 1;
		while k >= 0 {
			a = 1.0 / ((j + k) * (j - k));
			a1 = (2 * j - 1) * v.z * a;
			a2 = rr * a;
			le.set_c(a1 * le.c(j - 1, k), j, k);
			le.set_s(a1 * le.s(j - 1, k), j, k);
			if k < j - 1 {
				le.set_c((le.c(j, k) - a2 * le.c(j - 2, k)), j, k);
				le.set_s((le.s(j, k) - a2 * le.s(j - 2, k)), j, k);
			}
			k -= 1;
		}
	}
}

proc evalMpProdLL(inout le1: mp_terms, inout le2: mp_terms, 
	inout le3: mp_terms, maxOrd: int) {
  	var s2, s3, v1c2, v1c3, v1s2, v1s3: real;
	var j3, k3: int;

	for j1 in [1..maxOrd+1] {
		for k1 in [1..j1+1] {
			le1.set_c(0.0, j1, k1);
			le1.set_s(0.0, j1, k1);
			for j2 in [1..j1+1] {
				j3 = j1 - j2;
				for k2 in [max(-j2, k1-j3)..min(j2, k1+j3)] {
					k3 = k1 - k2;
					v1c2 = le2.c(j2, abs(k2));
					v1s2 = le2.s(j2, abs(k2));
					if k2 < 0 then v1s2 = -v1s2;
					v1c3 = le3.c(j3, abs(k3));
					v1s3 = le3.s(j3, abs(k3));
					if k3 < 0 then v1s3 = -v1s3;
					if k2 < 0 && isOdd(k2) then s2 = -1.0;
					else s2 = 1.0;
					if k3 < 0 && isOdd(k3) then s3 = -1.0;
					else s3 = 1.0;
					le1.add_c(s2 * s3 * (v1c2 * v1c3 - v1s2 * v1s3), j1, k1);
					le1.add_s(s2 * s3 * (v1c2 * v1c3 + v1s2 * v1s3), j1, k1);
				}
			}
		}
	}
}

proc combineMpCell() {
	var le, le2: mp_terms;
	var rShift: vector;
	var mpCellsN, m1v, m2v: vector_i;
	var m1, m2: int;
	
	mpCellsN = 2 * mpCells;
	for m1z in [0..mpCells.z] {
		for m1y in [0..mpCells.y] {
			for m1x in [0..mpCells.x] {
				m1v.set(m1x, m1y, m1z);
				m1 = vlinear(m1v, mpCells);
				for j in [1..maxOrd+1] {
					for k in [1..j+1] {
						mpCell((curLevel, m1)).le.set_c(0.0, j, k);
						mpCell((curLevel, m1)).le.set_s(0.0, j, k);
					}
				}
				mpCell((curLevel, m1)).occ = 0;
				for iDir in [0..7] {
					m2v = 2 * m1v;
					rShift = (-0.25) * cellWid;
					if isOdd(iDir) {
						m2v.x += 1;
						rShift.x *= -1.0;
					}
					if isOdd(iDir / 2) {
						m2v.y += 1;
						rShift.y *= -1.0;
					}
					if (isOdd(iDir / 4)) {
						m2v.z += 1;
						rShift.z *= -1.0;
					}
					m2 = vlinear(m2v, mpCellsN);
					if mpCell((curLevel + 1, m2)).occ == 0 then continue;
					mpCell((curLevel, m1)).occ += 
						mpCell((curLevel + 1, m2)).occ;
					evalMpL(le2, rShift, maxOrd);
					evalMpProdLL(le, mpCell((curLevel+1, m2)).le, le2, maxOrd);
					for j in [1..maxOrd] {
						for k in [1..j] {
							mpCell((curLevel, m1)).le.add_c(le.c(j, k), j, k);
							mpCell((curLevel, m1)).le.add_s(le.s(j, k), j, k);
						}
					}
				}
			}
		}
	}
}

proc gatherWellSepLo() {
	var m1v, m2v: vector_i;
	var m1, m2: int;

	for m1z in [0..mpCells.z] {
		for m1y in [0..mpCells.y] {
			for m1x in [0..mpCells.x] {
				m1v.set(m1x, m1y, m1z);
				m1 = vlinear(m1v, mpCells);
				if mpCell((curLevel, m1)).occ == 0 then continue;
				for m2z in [m1v.llim_z(wellSep)..m1v.hlim_z(wellSep)] {
					for m2y in [m1v.llim_y(wellSep)..m1v.hlim_y(wellSep)] {
						for m2x in [m1v.llim_z(wellSep)..m1v.hlim_z(wellSep)] {
							m2v.set(m2x, m2y, m2z);
							/* RESUME */
						}
					}
				}
			}
		}
	}
}

proc propagateCellLo() {
}

proc computeFarCellInt() {
}

proc computeNearCellInt() {
}

proc multipoleCalc() {
	var le: mp_terms;
	var invWid, cMid, dr: vector;
	var cc, m1v: vector_i;
	var c, m1, j1: int;

	mpCells.set(maxCellsEdge);

	// Assign mpCells
	invWid = mpCells / region;
	for n in [nMol+1..nMol+mpCells.prod()] do mpCellList[n] = -1;
	for n in mol.domain {
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, mpCells) + nMol;
		mpCellList(n) = mpCellList(c);
		mpCellList(c) = n;
	}

	cellWid = region / mpCells;

	// Evaluate mpCells
	for m1z in [0..mpCells.z] {
		for m1y in [0..mpCells.y] {
			for m1x in [0..mpCells.x] {
				m1v.set(m1x, m1y, m1z);
				m1 = vlinear(m1v, mpCells);
				mpCell((maxLevel, m1)).occ = 0;
				for j in [1..maxOrd+1] {
					for k in [0..j] {
						mpCell((maxLevel, m1)).le.set_c(0.0, j, k);
						mpCell((maxLevel, m1)).le.set_s(0.0, j, k);
					}
				}
				if mpCellList(m1 + nMol) >= 0 {
					cMid = m1v + 0.5;
					cMid *= cellWid;
					cMid += (-0.5) * region;
					j1 = mpCellList(m1 + nMol);
					while j1 >= 0 {
						mpCell((maxLevel, m1)).occ += 1;
						dr = mol(j1).r - cMid;
						evalMpL (le, dr, maxOrd);
						for j in [1..maxOrd+1] {
							for k in [1..j+1] {
								mpCell((maxLevel, m1)).le.add_c(
									mol(j1).chg * le.c(j, k), j, k);
								mpCell((maxLevel, m1)).le.add_s(
									mol(j1).chg * le.s(j, k), j, k);
							}
						}
						j1 = mpCellList(j1);
					}
				}
			}
		}
	}

	curCellsEdge = maxCellsEdge;
	curLevel = maxLevel - 1;
	while curLevel >= 2 {
		curCellsEdge /= 2;
		mpCells.set(curCellsEdge);
		cellWid = region / mpCells;
		combineMpCell();
		curLevel -= 1;
	}

	for m1 in [1..64] {
		for j in [1..maxOrd+1] {
			for k in [1..j+1] {
				mpCell((2, m1)).me.set_c(0.0, j, k);
				mpCell((2, m1)).me.set_s(0.0, j, k);
			}
		}
	}

	curCellsEdge = 2;
	for curLevel in [2..maxLevel] {
		curCellsEdge *= 2;
		mpCells.set(curCellsEdge);
		cellWid = region / mpCells;
		gatherWellSepLo();
		if curLevel < maxLevel then propagateCellLo();
	}
	computeFarCellInt();
	computeNearCellInt();
}

proc computeWallForces() {
}
	
proc applyThermostat() {
}

proc evalRdf() {
	var dr: vector;
	var deltaR, rr, normFac: real;
	var n: int;

	if countRdf == 0 {
		for n in [1..sizeHistRdf] {
			histRdf(0, n) = 0.0;
			histRdf(1, n) = 0.0;
		}
	}

	deltaR = rangeRdf / sizeHistRdf;
	for j1 in [1..nMol-1] {
		for j2 in [j1+1..nMol] {
			dr = mol(j1).r - mol(j2).r;
			rr = dr.lensq();
			if rr < rangeRdf ** 2 {
				n = (sqrt(rr) / deltaR): int;
				if mol(j1).chg * mol(j2).chg > 0 then histRdf(1, n) += 1;
				else histRdf(0, n) += 1;
			}
		}
	}

	countRdf += 1;
	if countRdf == limitRdf {
		normFac = region.prod() / (2.0 * PI * (deltaR ** 3) * (nMol ** 2) *
			countRdf);
		for k in [1..2] {
			cumRdf(k, 0) = 0.0;
			for n in [2..sizeHistRdf] do
				cumRdf(k, n) = cumRdf(k, n - 1) + histRdf(k, n);
			for n in [1..sizeHistRdf] {
				histRdf(k, n) *= normFac / ((n - 0.5) ** 2);
				cumRdf(k, n) /= 0.5 * nMol * countRdf;
			}
		}
	
		var rb: real;
		writeln("rdf");
		for n in [1..sizeHistRdf] {
			rb = (n + 0.5) * rangeRdf / sizeHistRdf;
			write(rb);
			for k in [1..2] do
				write(histRdf(k, n), " ", cumRdf(k, n));
			write("\n");
		}
		stdout.flush();
		countRdf = 0;
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
	computeForces();
	multipoleCalc();
	computeWallForces();
	applyThermostat();

	// Leapfrog
	for m in mol do m.rv += (0.5 * deltaT) * m.ra;

	// Evaluate thermodynamics proerties
	var vv, vvMax: real;

	vSum.zero();
	vvSum = 0;
	vvMax = 0.0;
	for m in mol {
		vSum += m.rv;
		vv = m.rv.lensq();
		vvSum += vv;
		vvMax = max(vvMax, vv);
	}
	dispHi += sqrt(vvMax) * deltaT;
	if dispHi > 0.5 * rNebrShell then nebrNow = 1;
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;

	// Adjust initial temp
	var vFac: real;

	if stepCount < stepEquil {
		kinEnInitSum += kinEnergy.v;
		if stepCount % stepInitlzTemp == 0 {
			kinEnInitSum /= stepInitlzTemp;
			vFac = velMag / sqrt(2.0 * kinEnInitSum);
			for m in mol do m.rv.scale(vFac);
			kinEnInitSum = 0.0;
		}
	}

	// Accumulate thermodynamics properties
	totEnergy.acc();
	kinEnergy.acc();

	if stepCount % stepAvg == 0 {
		totEnergy.avg(stepAvg);
		kinEnergy.avg(stepAvg);

		// Print summary
		writeln("\t", stepCount, "\t", timeNow, "\t", vSum.csum() / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2, "\t", kinEnergy.sum,
			"\t", kinEnergy.sum2);
		
		totEnergy.zero();
		kinEnergy.zero();
	}

	if stepCount >= stepEquil && (stepCount - stepEquil) % stepRdf == 0 then
		evalRdf();
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
		if stepCount >= stepLimit then moreCycles = 0;
	};
}
