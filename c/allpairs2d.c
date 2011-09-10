/****************************************************************************
 * Copyright (C) 2011  Nan Dun <dunnan@yl.is.s.u-tokyo.ac.jp>
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

/* allpairs2d.c */

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	int steps = 0;
	int steps_limit = 10;
	
	/* Initilization */

	while (steps < steps_limit) {
		printf("Conduct step %d\n", steps);
		steps++;
	}
	
	return 0;
}
