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
var timeNow: real;

proc init() {
	// Initial coordinates
	var c: vector2d, gap: vector2d;
	
	gap = region / initCell;
	for d in mol.domain {
		c = ((0.5, 0.5) + d) * gap;
		c += (-0.5, -0.5) * region;
		mol(d)(1) = c;
	}

	// Initial velocities
	for m in mol {
		m(2) = vrand2d() * (velMag, velMag);
		vSum += m(2);
	}
	for m in mol {
		m(2) += (-1.0 / nMol, -1.0 / nMol) * vSum;
	}

	// Initial accelerations
	for m in mol {
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
}

proc main() {
	init();
	while (moreCycles) {
		step();
		if (stepCount >= stepLimit) then
			moreCycles = 0;
	};
};
