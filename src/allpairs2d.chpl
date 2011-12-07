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

use BlockDist, CyclicDist;
use common;

record mol2d {
	var r, rv, ra: vector2d;
	var onlocale: int;
}

var _initUcellX, _initUcellY: int;
config const deltaT: real = 0.005;
config const density: real = 0.8;
config const temperature: real = 1.0;
config const initUcellD: int = 0;
config const initUcellX: int = 0;
config const initUcellY: int = 0;
config const stepAvg: int = 100;
config const stepEquil: int = 0;
config const stepLimit: int = 10000;
config const profLevel: int = 0;
const NDIM: int = 2;

var rCut, rrCut, velMag, timeNow, uSum, virSum, vvSum: real;
var initUcell: vector2d_i; 
var region, vSum: vector2d;
var nMol, stepCount, moreCycles: int; 
var kinEnergy, totEnergy, pressure: prop;
var timer: elapsedTimer;
var uSumLock$: sync bool; // atomic statement is not ready yet

_initUcellX = 20;
_initUcellY = 20;
if initUcellD > 0  {
	_initUcellX = initUcellD;
	_initUcellY = initUcellD;
}
if initUcellX > 0 then _initUcellX = initUcellX;
if initUcellY > 0 then _initUcellY = initUcellY;

proc printConfig() {
	writeln(
		"deltaT          ", deltaT, "\n",
		"density         ", density, "\n",
		"initUcell       ", _initUcellX, " ",  _initUcellY, "\n",
		"stepAvg         ", stepAvg, "\n",
		"stepEquil       ", stepEquil, "\n",
		"stepLimit       ", stepLimit, "\n",
		"temperature     ", temperature, "\n",
		"----");
	stdout.flush();
}

proc step(mol) {
	stepCount += 1;
	timeNow = stepCount * deltaT;
	
	if profLevel == 1 then timer.start();
	forall m in mol {
		// Leapfrog
		m.rv += (0.5 * deltaT) * m.ra;
		m.r += deltaT * m.rv;
		// Apply boundary condition
		m.r = vwrap(m.r, region);
		// Re-initial acceleration
		m.ra.zero();
	}
	if profLevel == 1 then timer.stop("leapFrog(1)");

	// Compute forces
	if profLevel == 1 then timer.start();
	uSum = 0;
	virSum = 0;
	uSumLock$.reset();
	uSumLock$ = true;

	forall m in mol {
		var dr: vector2d;
		var fcVal, rr, rri, rri3: real;
		var uSumLocal, virSumLocal: real;
		uSumLocal = 0.0;
		virSumLocal = 0.0;
		for m2 in mol {
			dr = vwrap((m.r - m2.r), region);
			rr = dr.lensq();
			if rr > 0 && rr < rrCut {
				rri = 1.0 / rr;
				rri3 = rri ** 3;
				fcVal = 48 * rri3 * (rri3 - 0.5) * rri;
				m.ra += fcVal * dr;
				uSumLocal += (4 * rri3 * (rri3 - 1.0) + 1) * 0.5;
				virSumLocal += fcVal * rr * 0.5;
			}
		}
		/* FIX: hang when numThreadsPerLocale < 5 */
		uSumLock$;
		uSum += uSumLocal;
		virSum += virSumLocal;
		uSumLock$ = true;
	}
	if profLevel == 1 then timer.stop("computeForces");
	
	// Leafrog
	if profLevel == 1 then timer.start();
	forall m in mol do m.rv += (0.5 * deltaT) * m.ra;
	if profLevel == 1 then timer.stop("leapFrog(2)");

	// Evaluate thermodynamics properties
	if profLevel == 1 then timer.start();
	vSum.zero();
	vvSum = 0;
	// reduce does not support operator overloading?
	for m in mol do vSum += m.rv;
	vvSum = + reduce (mol.rv.lensq());
	kinEnergy.v = 0.5 * vvSum / nMol;
	totEnergy.v = kinEnergy.v + uSum / nMol;
	pressure.v = density * (vvSum + virSum) / (nMol * NDIM);
		
	// Accumulate thermodynamics properties
	totEnergy.acc();
	kinEnergy.acc();
	pressure.acc();
	if profLevel == 1 then timer.stop("evalThermo");
		
	if stepCount % stepAvg == 0 {
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
		
		totEnergy.zero();
		kinEnergy.zero();
		pressure.zero();
	}
}

proc main() {
	printConfig();

	// Initialization
	if profLevel == 1 then timer.start();
	initUcell = (_initUcellX, _initUcellY);
	nMol = initUcell.prod();
	rCut = 2.0 ** (1.0 / 6.0);
	rrCut = rCut ** 2;
	region = 1.0 / sqrt(density) * initUcell;
	velMag = sqrt(NDIM * (1.0 - 1.0 / nMol * temperature));
	stepCount = 0;

	const molDomLit: domain(1) = [1..nMol];
//	var molDom: domain(1) dmapped Cyclic(startIdx=molDomLit.low) = molDomLit;
	var molDom: domain(1) dmapped Block(molDomLit) = molDomLit;
	var mol: [molDom] mol2d;
	kinEnergy = new prop();
	totEnergy = new prop();
	pressure = new prop();

	// Initial coordinates
	var c, gap: vector2d;
	var n: int;
	
	gap = region / initUcell;
	n = 1;
	for (ny, nx) in [0..initUcell.y-1, 0..initUcell.x-1] {
		mol(n).r = (nx + 0.5, ny + 0.5) * gap - (0.5 * region);
		n += 1;
	}

	if profLevel == 1 {
		forall m in mol do m.onlocale = here.id;
		write("Distribution of molecules: ");
		for m in mol do	write(m.onlocale, " ");
		writeln("");
	}

	// Initial velocities and accelerations
	vSum.zero();
	for m in mol {
		m.rv = velMag * vrand2d();
		vSum += m.rv;
	}
	for m in mol {
		m.rv += (-1.0 / nMol) * vSum;
		m.ra.zero();	// accelerations
	}
	
	totEnergy.zero();
	kinEnergy.zero();
	pressure.zero();
	if profLevel == 1 then timer.stop("init");
	
	// Step
	moreCycles = 1;
	while (moreCycles) {
		step(mol);
		if (stepCount >= stepLimit) then moreCycles = 0;
	};
}
