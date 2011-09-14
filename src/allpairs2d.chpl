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

/* allpairs2d.chpl */

use common;

config const deltaT: real = 0.005;
config const density: real = 0.8;
config const temperature: real = 1.0;
config const initCellX: int = 20;
config const initCellY: int = 20;
config const stepAvg: int = 100;
config const stepEquil: int = 0;
config const stepLimit: int = 10000;
const NDIM: int = 2;

var rCut, velMag, timeNow, uSum, virSum, vvSum: real;
var initCell, region, vSum: vector2d;
var nMol, stepCount, moreCycles: int; 
var mol: [1..initCellX, 1..initCellY] mol2d;
var kinEnergy, totEnergy, pressure: Prop;

proc init() {
	// Setup parameters
	initCell.set(initCellX, initCellY);
	rCut = 2.0 ** (1.0 / 6.0);
	region.set(1.0 / sqrt(density) * initCellX, 
		1.0 / sqrt(density) * initCellY);
	nMol = initCellX * initCellY;
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	stepCount = 0;
	moreCycles = 1;
	vSum.zero();
	kinEnergy = new Prop();
	totEnergy = new Prop();
	pressure = new Prop();

	// Initial coordinates
	var c, gap: vector2d;
	
	gap = region / initCell;
	for d in mol.domain do // NOTE: index of domain starts from (1, 1)
		mol(d).r = ((-0.5, -0.5) + d) * gap - 0.5 * region;

	// Initial velocities and accelerations
	for m in mol {
		m.rv = velMag * vrand2d();
		vSum += m.rv;
	}
	for m in mol {
		m.rv += (-1.0 / nMol) * vSum;
		m.ra.zero();
	}
	
	totEnergy.setZero();
	kinEnergy.setZero();
	pressure.setZero();
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
