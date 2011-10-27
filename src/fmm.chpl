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
config const nebrTabFac: int = 12;
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
	nebrTabMax, nebrTabLen, curCellsEdge, curLevel: int;
var nebrNow: bool;
var molDom: domain(1) = [1..1];
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var nebrTabDom: domain(1) = [1..1];
var nebrTab: [nebrTabDom] int;
var mpCellDom: domain(2);
var mpCell: [mpCellDom] mp_cell;
var maxCellsEdge, maxOrd: int;
var mpCellListDom: domain(1) = [1..1];
var mpCellList: [mpCellListDom] int;
var histRdfDom, cumRdfDom: domain(2) = [1..1, 1..1];
var histRdf: [histRdfDom] real;
var cumRdf: [cumRdfDom] real;
var kinEnergy, totEnergy: prop;
var timer: elapsedTimer;

proc printConfig() {
	writeln(
		"chargeMag       ", chargeMag, "\n",
		"deltaT          ", deltaT, "\n",
		"density         ", density, "\n",
		"initUcell       ", initUcellX, " ",initUcellY," ",initUcellZ,"\n",
		"limitRdf        ", limitRdf, "\n",
		"maxLevel        ", maxLevel, "\n",
		"nebrTabFac      ", nebrTabFac, "\n",
		"rangeRdf        ", rangeRdf, "\n",
		"rNebrShell      ", rNebrShell, "\n",
		"sizeHistRdf     ", sizeHistRdf, "\n",
		"stepAvg         ", stepAvg, "\n",
		"stepEquil       ", stepEquil, "\n",
		"stepInitlzTemp  ", stepInitlzTemp, "\n",
		"stepLimit       ", stepLimit, "\n",
		"stepRdf         ", stepRdf, "\n",
		"temperature     ", temperature, "\n",
		"wellSep         ", wellSep, "\n",
		"----");
	stdout.flush();
}

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
	
	maxCellsEdge = 2 ** maxLevel;
	mpCells.set(maxCellsEdge);
	mpCellDom = [1..maxLevel, 1..mpCells.prod()];
	mpCellListDom = [1..(nMol + mpCells.prod())];
	histRdfDom = [1..2, 1..sizeHistRdf];
	cumRdfDom = [1..2, 1..sizeHistRdf];

	stepCount = 0;
	
	// Initial coordinates
	var c, gap: vector;
	var n: int;

	gap = region / initUcell;
	n = 1;
	for (nz, ny, nx) in [0..initUcell.z-1,0..initUcell.y-1,0..initUcell.x-1] {
		mol(n).r = (nx + 0.5, ny + 0.5, nz + 0.5) * gap - (0.5 * region);
		n += 1;
	}

	// Initial velocities, accelerations, and charges
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand();
		vSum += m.rv;
	}
	forall m in mol {
		m.rv += (-1.0 / nMol) * vSum;
		m.ra.zero();	// accelerations
		if randR() > 0.5 then m.chg = chargeMag;	// charges
		else m.chg = -chargeMag;
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	nebrNow = true;
	kinEnInitSum = 0.0;
}

iter iterMpCellList(n: int) {
	var i = mpCellList(n + nMol);
	while i >= 1 {
		yield i;
		i = mpCellList(i);
	}
}

iter iterMaxOrd(ord: int, init: int = 0) {
	var i, j: int = init;
	while i <= ord {
		j = 0;
		while j <= i {
			yield (i, j);
			j += 1;
		}
		i += 1;
	}
}
proc buildNebrList() {
	var dr, invWid: vector;
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
			if m2v.x < 0 || m2v.x >= cells.x || 
			   m2v.y < 0 || m2v.y >= cells.y || m2v.z >= cells.z 
			   then continue;
			m2 = vlinear(m2v, cells) + nMol;
			for j1 in iterCellList(m1, cellList) {
				for j2 in iterCellList(m2, cellList) {
					if (m1 != m2 || j2 < j1) {
						dr = mol(j1).r - mol(j2).r;
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
	var rrCut = rCut ** 2;
	forall m in mol do m.ra.zero();
	uSum = 0.0;
	for i in [1..nebrTabLen] {	// nebrTab.domain excced the nebrTabLen
		var dr: vector;
		var rr, rri, rri3, fcVal, uVal: real;
		var j1, j2: int;
		j1 = nebrTab(2 * i - 1);
		j2 = nebrTab(2 * i);
		dr = mol(j1).r - mol(j2).r;
		rr = dr.lensq();
		if rr < rrCut {
			rri = 1.0 / rr;
			rri3 = rri ** 3;
			fcVal = 48.0 * rri3 * (rri3 - 0.5) * rri;
			uVal = 4.0 * rri3 * (rri3 - 1.0) + 1.0;
			mol(j1).ra += fcVal * dr;
			mol(j2).ra -= fcVal * dr;
			uSum += uVal;
		}
	}
}

proc evalMpL (inout le: mp_terms, v: vector, maxOrd: int) {
	var rr: real;

	rr = v.lensq();
	le.set_c(1.0, 0, 0);
	le.set_s(0.0, 0, 0);
	for j in [1..maxOrd] {
		var a, a1, a2: real;
		a = - 1.0 / (2 * j);
		le.set_c(a*(v.x*le.c(j-1, j-1) - v.y * le.s(j-1, j-1)), j, j);
		le.set_s(a*(v.y*le.c(j-1, j-1) + v.x * le.s(j-1, j-1)), j, j);
		for k in iterDescend(j - 1, 0) {
			a = 1.0 / ((j + k) * (j - k));
			a1 = (2 * j - 1) * v.z * a;
			a2 = rr * a;
			le.set_c(a1 * le.c(j - 1, k), j, k);
			le.set_s(a1 * le.s(j - 1, k), j, k);
			if k < j - 1 {
				le.sub_c(a2 * le.c(j - 2, k), j, k);
				le.sub_s(a2 * le.s(j - 2, k), j, k);
			}
		}
	}
}

proc evalMpProdLL(inout le1: mp_terms, le2: mp_terms, le3: mp_terms, 
	maxOrd: int) {
	for (j1, k1) in iterMaxOrd(maxOrd) {
		var s2, s3, v1c2, v1c3, v1s2, v1s3: real;
		var j3, k3: int;
		le1.set_c(0.0, j1, k1);
		le1.set_s(0.0, j1, k1);
		for j2 in iterAscend(0, j1) {
			j3 = j1 - j2;
			for k2 in iterAscend(max(-j2, k1-j3), min(j2, k1+j3)) {
				k3 = k1 - k2;
				v1c2 = le2.c(j2, abs(k2));
				v1s2 = le2.s(j2, abs(k2));
				if k2 < 0 then v1s2 = -v1s2;
				v1c3 = le3.c(j3, abs(k3));
				v1s3 = le3.s(j3, abs(k3));
				if k3 < 0 then v1s3 = -v1s3;
				if k2 < 0 && isOdd(k2) then s2 = -1.0; else s2 = 1.0;
				if k3 < 0 && isOdd(k3) then s3 = -1.0; else s3 = 1.0;
				le1.add_c(s2 * s3 * (v1c2 * v1c3 - v1s2 * v1s3), j1, k1);
				le1.add_s(s2 * s3 * (v1s2 * v1c3 + v1c2 * v1s3), j1, k1);
			}
		}
	}
}

proc evalMpM(inout me: mp_terms, inout v: vector, maxOrd: int) {
	var rri = 1.0 / v.lensq();
	me.set_c(sqrt(rri), 0, 0);
	me.set_s(0.0, 0, 0);
	for j in [1..maxOrd] {
		var a, a1, a2: real;
		a = - (2 * j - 1) * rri;
		me.set_c(a * (v.x * me.c(j-1, j-1) - v.y * me.s(j-1, j-1)), j, j);
		me.set_s(a * (v.y * me.c(j-1, j-1) + v.x * me.s(j-1, j-1)), j, j);
		for k in iterDescend(j - 1, 0) {
			a1 = (2 * j - 1) * v.z * rri;
			a2 = (j - 1 + k) * (j - 1 - k) * rri;
			me.set_c(a1 * me.c(j - 1, k), j, k);
			me.set_s(a1 * me.s(j - 1, k), j, k);
			if k < j - 1 {
				me.sub_c(a2 * me.c(j - 2, k), j, k);
				me.sub_s(a2 * me.s(j - 2, k), j, k);
			}
		}
	}
}

proc evalMpProdLM(inout me1:mp_terms, inout le2:mp_terms, 
	inout me3: mp_terms, maxOrd: int) {
	for (j1, k1) in iterMaxOrd(maxOrd) {
		var s2, s3, v1c2, v1s2, vmc3, vms3: real;
		var j3, k3: int;
		me1.set_c(0.0, j1, k1);
		me1.set_s(0.0, j1, k1);
		for j2 in iterAscend(0, maxOrd-j1) {
			j3 = j1 + j2;
			for k2 in iterAscend(max(-j2, -k1-j3), min(j2, -k1+j3)) {
				k3 = k1 + k2;
				v1c2 = le2.c(j2, abs(k2));
				v1s2 = le2.s(j2, abs(k2));
				if k2 < 0 then v1s2 = -v1s2;
				vmc3 = me3.c(j3, abs(k3));
				vms3 = me3.s(j3, abs(k3));
				if k3 < 0 then vms3 = -vms3;
				if k2 < 0 && isOdd(k2) then s2 = -1.0; else s2 = 1.0;
				if k3 < 0 && isOdd(k3) then s3 = -1.0; else s3 = 1.0;
				me1.add_c(s2 * s3 * (v1c2 * vmc3 + v1s2 * vms3), j1, k1);
				me1.add_s(s2 * s3 * (v1c2 * vms3 - v1s2 * vmc3), j1, k1);
			}
		}
	}
}

proc evalMpForce(inout f: vector, inout u: real, inout me: mp_terms, 
		inout le: mp_terms, maxOrd: int) {

	f.zero();
	for (j, k) in iterMaxOrd(maxOrd, 1) {
		var fc, fs: vector;
		if k < j - 1 {
			fc.x = le.c(j - 1, k + 1);
			fc.y = le.s(j - 1, k + 1);
			fs.x = le.s(j - 1, k + 1);
			fs.y = -le.c(j - 1, k + 1);
		} else { 
			fc.x = 0.0; 
			fc.y = 0.0; 
			fs.x = 0.0; 
			fs.y = 0.0; 
		}
		if k < j { 
			fc.z = le.c(j - 1, k);
			fs.z = le.s(j - 1, k);
		} else { 
			fc.z = 0.0; 
			fs.z = 0.0;
		}
		if k > 0 {
			fc.x -= le.c(j - 1, k - 1);
			fc.y += le.s(j - 1, k - 1);
			fc.z *= 2.0;
			fs.x -= le.s(j - 1, k - 1);
			fs.y -= le.c(j - 1, k - 1);
			fs.z *= 2.0;
		}
		f = f + me.c(j, k) * fc + me.s(j, k) * fs;
	}
	u = 0.0;
	for (j, k) in iterMaxOrd(maxOrd) {
		var a: real;
		a = me.c(j, k) * le.c(j, k) + me.s(j, k) * le.s(j, k);
		if k > 0 then a *= 2.0;
		u += a;
	}
}

proc combineMpCell() {
	var mpCellsN: vector_i;
	mpCellsN = 2 * mpCells;
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var le, le2: mp_terms;
		var rShift: vector;
		var m1v, m2v: vector_i;
		var m1, m2: int;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		for (j, k) in iterMaxOrd(maxOrd) {
			mpCell(curLevel, m1).le.set_c(0.0, j, k);
			mpCell(curLevel, m1).le.set_s(0.0, j, k);
		}
		mpCell(curLevel, m1).occ = 0;
		for iDir in iterAscend(0, 7) {
			m2v = 2 * m1v;
			rShift = (-0.25) * cellWid;
			if isOdd(iDir) { m2v.x += 1; rShift.x *= -1.0; }
			if isOdd(iDir / 2) { m2v.y += 1; rShift.y *= -1.0; }
			if (isOdd(iDir / 4)) { m2v.z += 1; rShift.z *= -1.0; }
			m2 = vlinear(m2v, mpCellsN);
			if mpCell(curLevel + 1, m2).occ == 0 then continue;
			mpCell(curLevel, m1).occ += mpCell(curLevel + 1, m2).occ;
			evalMpL(le2, rShift, maxOrd);
			evalMpProdLL(le, mpCell(curLevel+1, m2).le, le2, maxOrd);
			for (j, k) in iterMaxOrd(maxOrd) {
				mpCell(curLevel, m1).le.add_c(le.c(j, k), j, k);
				mpCell(curLevel, m1).le.add_s(le.s(j, k), j, k);
			}
		}
	}
	
}

proc gatherWellSepLo() {
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var le, me, me2: mp_terms;
		var rShift: vector;
		var m1v, m2v: vector_i;
		var m1, m2: int;
		var s: real;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		if mpCell(curLevel, m1).occ == 0 {
			for (m2x, m2y, m2z) in iterAscend3(
				m1v.ll_x(wellSep), m1v.hl_x(wellSep),
				m1v.ll_y(wellSep), m1v.hl_y(wellSep),
				m1v.ll_z(wellSep), m1v.hl_z(wellSep)) {
				m2v.set(m2x, m2y, m2z);
				if m2v.x < 0 || m2v.x >= mpCells.x ||
				   m2v.y < 0 || m2v.y >= mpCells.y ||
				   m2v.z < 0 || m2v.z >= mpCells.z then continue;
				if abs(m2v.x - m1v.x) <= wellSep &&
				   abs(m2v.y - m1v.y) <= wellSep &&
				   abs(m2v.z - m1v.z) <= wellSep then continue;
				m2 = vlinear(m2v, mpCells);
				if mpCell(curLevel, m2).occ == 0 then continue;
				for (j, k) in iterMaxOrd(maxOrd) {
					if isOdd(j) {
						le.set_c(-1 * mpCell(curLevel, m2).le.c(j, k), j, k);
						le.set_s(-1 * mpCell(curLevel, m2).le.s(j, k), j, k);
					} else {
						le.set_c(mpCell(curLevel, m2).le.c(j, k), j, k);
						le.set_s(mpCell(curLevel, m2).le.s(j, k), j, k);
					}
				}
				rShift = (m2v - m1v) * cellWid;
				evalMpM(me2, rShift, maxOrd);
				evalMpProdLM(me, le, me2, maxOrd);
				for (j, k) in iterMaxOrd(maxOrd) {
					mpCell(curLevel, m1).me.add_c(me.c(j, k), j, k);
					mpCell(curLevel, m1).me.add_s(me.s(j, k), j, k);
				}
			}
		}
	}
}

proc propagateCellLo() {
	var mpCellsN: vector_i;

	mpCellsN = 2 * mpCells;
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var le: mp_terms;
		var rShift: vector;
		var m1v, m2v: vector_i;
		var m1, m2: int;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		if mpCell(curLevel, m1).occ != 0 {
			for iDir in iterAscend(0, 7) {
				m2v = 2 * m1v;
				rShift = (-0.25) * cellWid;
				if isOdd(iDir) { m2v.x += 1; rShift.x *= -1.0; }
				if isOdd(iDir / 2) { m2v.y += 1; rShift.y *= -1.0; }
				if isOdd(iDir / 4) { m2v.z += 1; rShift.z *= -1.0; }
				m2 = vlinear(m2v, mpCellsN);
				evalMpL(le, rShift, maxOrd);
				evalMpProdLM(mpCell(curLevel + 1, m2).me, le,
					mpCell(curLevel, m1).me, maxOrd);
			}
		}
	}
}

proc computeFarCellInt() {
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var le: mp_terms;
		var cMid, dr, f: vector;
		var m1v: vector_i;
		var u: real;
		var m1: int;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		if mpCell(maxLevel, m1).occ != 0 {
			cMid = (m1v + 0.5) * cellWid - 0.5 * region;
			for j in iterMpCellList(m1) {
				dr = mol(j).r - cMid;
				evalMpL(le, dr, maxOrd);
				evalMpForce(f, u, mpCell(maxLevel, m1).me, le, maxOrd);
				mol(j).ra = mol(j).ra - mol(j).chg * f;
				uSum += 0.5 * mol(j).chg * u;
			}
		}
	}
}

proc computeNearCellInt() {
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var dr, ft: vector;
		var m1v, m2v: vector_i;
		var qq, ri: real;
		var m1, m2, m2xLo, m2yLo: int;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		if mpCell(maxLevel, m1).occ != 0 {
			for m2z in iterAscend(m1z, min(m1v.z+wellSep, mpCells.z-1)) {
				if m2z == m1z then m2yLo = m1y;
				else m2yLo = max(m1y - wellSep, 0);
				for m2y in iterAscend(m2yLo, min(m1v.y+wellSep, mpCells.y-1)) {
					if m2z == m1z && m2y == m1y then m2xLo = m1x;
					else m2xLo = max(m1x - wellSep, 0);
					for m2x in iterAscend(m2xLo, 
						min(m1v.x+wellSep,mpCells.x-1)) {
						m2v.set(m2x, m2y, m2z);
						m2 = vlinear(m2v, mpCells);
						if mpCell(maxLevel, m2).occ != 0 {
							for j1 in iterMpCellList(m1) {
								for j2 in iterMpCellList(m2) {
									if m1 != m2 || j2 < j1 {
										dr = mol(j1).r - mol(j2).r;
										ri = 1.0 / dr.len();
										qq = mol(j1).chg * mol(j2).chg;
										ft = qq * (ri ** 3) * dr;
										mol(j1).ra += ft;
										mol(j2).ra += ft;
										uSum += qq * ri;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

proc multipoleCalc() {
	var invWid: vector;

	mpCells.set(maxCellsEdge);

	// Assign mpCells
	invWid = mpCells / region;
	forall n in [nMol + 1..nMol + mpCells.prod()] do mpCellList(n) = -1;
	forall n in mol.domain {
		var cc: vector_i;
		var c: int;
		cc = (mol(n).r + 0.5 * region) * invWid;
		c = vlinear(cc, mpCells) + nMol;
		mpCellList(n) = mpCellList(c);
		mpCellList(c) = n;
	}
	cellWid = region / mpCells;

	// Evaluate mpCells
	forall (m1z, m1y, m1x) in [0..mpCells.z-1,0..mpCells.y-1,0..mpCells.x-1] {
		var le: mp_terms;
		var cMid, dr: vector;
		var m1v: vector_i;
		var m1: int;
		m1v.set(m1x, m1y, m1z);
		m1 = vlinear(m1v, mpCells);
		mpCell(maxLevel, m1).occ = 0;
		for (j, k) in iterMaxOrd(maxOrd) {
			mpCell(maxLevel, m1).le.set_c(0.0, j, k);
			mpCell(maxLevel, m1).le.set_s(0.0, j, k);
		}
		if mpCellList(m1 + nMol) >= 1 {
			cMid = (m1v + 0.5) * cellWid - 0.5 * region;
			for j1 in iterMpCellList(m1) {
				mpCell(maxLevel, m1).occ += 1;
				dr = mol(j1).r - cMid;
				evalMpL (le, dr, maxOrd);
				for (j, k) in iterMaxOrd(maxOrd) {
					mpCell(maxLevel, m1).le.add_c(
						mol(j1).chg * le.c(j, k), j, k);
					mpCell(maxLevel, m1).le.add_s(
						mol(j1).chg * le.s(j, k), j, k);
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

	forall m1 in [1..64] {
		for (j, k) in iterMaxOrd(maxOrd) {
			mpCell(2, m1).me.set_c(0.0, j, k);
			mpCell(2, m1).me.set_s(0.0, j, k);
		}
	}

	curCellsEdge = 2;
	curLevel = 2;
	while curLevel <= maxLevel {
		curCellsEdge *= 2;
		mpCells.set(curCellsEdge);
		cellWid = region / mpCells;
		gatherWellSepLo();
		if curLevel < maxLevel then propagateCellLo();
		curLevel += 1;
	}
	
	computeFarCellInt();
	computeNearCellInt();
}

proc computeWallForces() {
	forall m in mol {
		var dr, rri, rri3: real;
		if m.r.x >= 0.0 then dr = m.r.x;
		else dr = - m.r.x;
		dr -= 0.5 * (region.x + rCut);
		if dr > -rCut {
			if m.r.x < 0 then dr = -dr;
			rri = 1.0 / (dr ** 2);
			rri3 = rri ** 3;
			m.ra.x += 48.0 * rri3 * (rri3 - 0.5) * rri * dr;
			uSum += 4.0 * rri3 * (rri3 - 1.0) + 1.0;
		}
		
		if m.r.y >= 0 then dr = m.r.y;
		else dr = - m.r.y;
		dr -= 0.5 * (region.y + rCut);
		if dr > -rCut {
			if m.r.y < 0 then dr = -dr;
			rri = 1.0 / (dr ** 2);
			rri3 = rri ** 3;
			m.ra.y += 48.0 * rri3 * (rri3 - 0.5) * rri * dr;
			uSum += 4.0 * rri3 * (rri3 - 1.0) + 1.0;
		}
		
		if m.r.z >= 0 then dr = m.r.z;
		else dr = - m.r.z;
		dr -= 0.5 * (region.z + rCut);
		if dr > -rCut {
			if m.r.z < 0 then dr = -dr;
			rri = 1.0 / (dr ** 2);
			rri3 = rri ** 3;
			m.ra.z += 48.0 * rri3 * (rri3 - 0.5) * rri * dr;
			uSum += 4.0 * rri3 * (rri3 - 1.0) + 1.0;
		}
	}
}
	
proc evalRdf() {
	var dr: vector;
	var deltaR, rr, normFac: real;
	var n: int;

	if countRdf == 0 {
		for n in [1..sizeHistRdf] {
			histRdf(1, n) = 0.0;
			histRdf(2, n) = 0.0;
		}
	}

	deltaR = rangeRdf / sizeHistRdf;
	for j1 in [1..nMol - 1] {
		for j2 in iterAscend(j1 + 1, nMol) {
			dr = mol(j1).r - mol(j2).r;
			rr = dr.lensq();
			if rr < rangeRdf ** 2 {
				n = (sqrt(rr) / deltaR): int;
				if mol(j1).chg * mol(j2).chg > 0 then histRdf(2, n) += 1;
				else histRdf(1, n) += 1;
			}
		}
	}

	countRdf += 1;
	if countRdf == limitRdf {
		normFac = region.prod() / (2.0 * PI * (deltaR ** 3) * 
			(nMol ** 2) * countRdf);
		for k in [1..2] {
			cumRdf(k, 1) = 0.0;
			for n in iterAscend(2, sizeHistRdf) do
				cumRdf(k, n) = cumRdf(k, n - 1) + histRdf(k, n);
			for n in iterAscend(1, sizeHistRdf) {
				histRdf(k, n) *= normFac / ((n - 0.5) ** 2);
				cumRdf(k, n) /= 0.5 * nMol * countRdf;
			}
		}
	
		var rb: real;
		writeln("rdf");
		for n in iterAscend(1, sizeHistRdf) {
			rb = (n - 0.5) * rangeRdf / sizeHistRdf;
			write(rb, " ", n, " ");
			for k in [1..2] do 	write(histRdf(k, n), " ", cumRdf(k, n), " ");
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
	forall m in mol {
		m.rv += (0.5 * deltaT) * m.ra;
		m.r += deltaT * m.rv;
	}

	if nebrNow {
		nebrNow = false;
		dispHi = 0.0;
		buildNebrList();
	}

	computeForces();
	multipoleCalc();
	computeWallForces();

	// Apply thermo statistics
	var s1, s2, vFac: real;
	var vt: vector;
	s1 = 0;
	s2 = 0;

	for m in mol {
		vt = m.rv + 0.5 * deltaT * m.ra;
		s1 += vdot(vt, m.ra);
		s2 += vt.lensq();
	}
	vFac = - s1 / s2;
	forall m in mol {
		vt = m.rv + 0.5 * deltaT * m.ra;
		m.ra += vFac * vt;
	}

	// Leapfrog
	forall m in mol do m.rv += (0.5 * deltaT) * m.ra;

	// Evaluate thermodynamics proerties
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

	// Adjust initial temp
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
		writeln("\t", stepCount, "\t", timeNow, 
			"\t", vSum.csum() / nMol,
			"\t", totEnergy.sum, "\t", totEnergy.sum2, 
			"\t", kinEnergy.sum, "\t", kinEnergy.sum2);
		stdout.flush();
		
		totEnergy.zero();
		kinEnergy.zero();
	}

	if stepCount >= stepEquil && 
	   (stepCount - stepEquil) % stepRdf == 0 then evalRdf();
}

proc main() {
	printConfig();
	init();
	moreCycles = 1;
	while (moreCycles) {
		step();
		if stepCount >= stepLimit then moreCycles = 0;
	};
}
