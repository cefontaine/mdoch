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
config const initUcellX: int = 2;
config const initUcellY: int = 2;
config const initUcellZ: int = 2;
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

var rCut, velMag: real;
var initUcell, cells, mpCells: vector_i;
var region, vSum: vector;
var nMol, nebrTabFac, nebrTabMax: int;
var timer: elapsedTimer;
var molDom: domain(1) = [1..1];
var mol: [molDom] mol3d;
var cellListDom: domain(1) = [1..1];
var cellList: [cellListDom] int;
var mpCellDom: domain(int);
var mpCell: [mpCellDom] mpcell;
var maxCellsEdge, maxOrd: int;

proc init() {
	// Setup parameters
	initUcell = (initUcellX, initUcellY, initUcellZ);
	rCut = 2.0 ** (1.0 / 6.0);
	region = 1.0 / (density ** (1.0/3.0)) * initUcell;
	nMol = initUcell.prod();
	nMol = 8;
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol) * temperature);
	cells = 1.0 / (rCut + rNebrShell) * region;
	nebrTabMax = nebrTabFac * nMol;
	maxOrd = MAX_MPEX_ORD;
	
	// Allocate storage
	molDom = [1..nMol];
	cellListDom = [1..(cells.prod()+nMol)];
	
	/* Synthesize irregualr domain
	 * According to specification, removing indices from super-domain is
	 * dangerous, so add up subdomains */
	/*
	mpCellDom = [1..maxLevel, 1..1];
	maxCellsEdge = 2;
	for n in [2..maxLevel] {
		maxCellsEdge *= 2;
		mpCells.set(maxCellsEdge);
		mpCellDom += [n..n, 1..mpCells.prod()];
	}
	*/
}

proc main() {
	//if profLevel >= 1 then timer.start();
	init();
	//if profLevel >= 1 then writeln("Init: ", timer.stop());
}
