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
 * Distributions Construction
 */

/* dist.chpl */

use BlockDist, CyclicDist;
use common;

config const nLoc: int = 10;

var locDomLiteral = [1..nLoc];
var locDom: domain(1) dmapped Cyclic(startIdx=locDomLiteral.low) = locDomLiteral;
var loc: [locDom] int; 

forall l in loc do l = here.id;
writeln(loc);

var sum = 0;
var sumLock$: sync bool;

sumLock$.reset();
sumLock$ = true;
forall l in loc {
	/* hang when numThreadsPerLocale < 5 */
	sumLock$;
	sum += l;
	sumLock$ = true;
}
writeln(sum);
