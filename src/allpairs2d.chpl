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

// Setup parameters
var initCell: (int, int) = (initCellX, initCellY);
var rCut: real = 2.0 ** (1.0/6.0);
var region: vector2d = (1.0 / sqrt(density) * initCellX, 
	1.0 / sqrt(density) * initCellY);
var nMol: int = initCellX * initCellY;
var velMag: real = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
var stepCount: int = 0;
var mol: [1..initCellX, 1..initCellX] mol2d;
var vSum: vector2d = (0.0, 0.0);
var kinEnergy, totEnergy, pressure: prop;
var moreCycles = 1;
var timeNow, uSum, virSum, vvSum: real;

proc init() {
	// Initial coordinates
	var c: vector2d, gap: vector2d;
	
	gap = region / initCell;
	for d in mol.domain do // NOTE: index of domain starts from (1, 1)
		mol(d)(1) = ((-0.5, -0.5) + d) * gap + (-0.5, -0.5) * region;

	// Initial velocities and accelerations
	for m in mol {
		m(2) = vrand2d() * (velMag, velMag);
		vSum += m(2);
	}
	for m in mol {
		m(2) += (-1.0 / nMol, -1.0 / nMol) * vSum;
		m(3) = (0.0, 0.0);
	}

	totEnergy(2) = 0.0;
	totEnergy(3) = 0.0;
	kinEnergy(2) = 0.0;
	kinEnergy(3) = 0.0;
	pressure(2) = 0.0;
	pressure(3) = 0.0;
}

proc step() {
	stepCount += 1;
	timeNow = stepCount * deltaT;
	
	// Leapfrog
	for m in mol {
		m(2) += (0.5 * deltaT, 0.5 * deltaT) * m(3);
		m(1) += (deltaT, deltaT) * m(2);
	}

	// Apply boundary condition
	for m in mol do
		m(1) = vwrap2d(m(1), region);

	// Compute forces
	var dr: vector2d;
	var fcVal, rr, rrCut, rri, rri3: real;
	var i, j, n: int;

	rrCut = rCut * rCut;
	for m in mol do
		m(3) = (0.0, 0.0);

	uSum = 0;
	virSum = 0;
	
	for d in mol.domain do {
		for d2 in mol.domain do {
			if d2 > d then {
				dr = mol(d)(1) - mol(d2)(1);
				dr = vwrap2d(dr, region);
				rr = dr(1) ** 2 + dr(2) ** 2;
				if rr < rrCut then {
					rri = 1.0 / rr;
					rri3 = rri ** 3;
					fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
					mol(d)(3) += (fcVal, fcVal) * dr;
					mol(d2)(3) += (-fcVal, -fcVal) * dr;
					uSum += 4 * rri3 * (rri3 - 1.0) + 1;
					virSum += fcVal * rr;
				}
			}
		}
	}

	// Leafrog
	for m in mol do
		m(2) += (0.5 * deltaT, 0.5 * deltaT) * m(3);

	// Evaluate themodynamics properties
	var vvMax: real;

	vSum = (0.0, 0.0);
	vvSum = 0;
	for m in mol {
		vSum += m(2);
		vvSum += m(2)(1) ** 2 + m(2)(2) ** 2;
	}
	kinEnergy(1) = 0.5 * vvSum / nMol;
	totEnergy(1) = kinEnergy(1) + uSum / nMol;
	pressure(1) = density * (vvSum + virSum) / (nMol * NDIM);
		
	// Accumulate themodynamics properties
	totEnergy(2) += totEnergy(1);
	totEnergy(3) += totEnergy(1) ** 2;
	kinEnergy(2) += kinEnergy(1);
	kinEnergy(3) += kinEnergy(1) ** 2;
	pressure(2) += pressure(1);
	pressure(3) += pressure(1) ** 2;
		
	var tmp: real;
	if stepCount % stepAvg == 0 then {
		totEnergy(2) /= stepAvg;
		totEnergy(3) = sqrt(max(totEnergy(3)/stepAvg - totEnergy(2) ** 2, 0));

		kinEnergy(2) /= stepAvg;
		kinEnergy(3) = sqrt(max(kinEnergy(3)/stepAvg - kinEnergy(2) ** 2, 0));

		pressure(2) /= stepAvg;
		pressure(3) = sqrt(max(pressure(3)/stepAvg - pressure(2) ** 2, 0));

		// Print summary
		writeln("\t", stepCount, "\t", timeNow, 
			"\t", (vSum(1) + vSum(2)) / nMol,
			"\t", totEnergy(2), "\t", totEnergy(3),
			"\t", kinEnergy(2), "\t", kinEnergy(3),
			"\t", pressure(2), "\t", pressure(3));
		stdout.flush();
		
		totEnergy(2) = 0.0;
		totEnergy(3) = 0.0;
		kinEnergy(2) = 0.0;
		kinEnergy(3) = 0.0;
		pressure(2) = 0.0;
		pressure(3) = 0.0;
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
