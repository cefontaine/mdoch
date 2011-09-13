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

/* common.h */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>
#include <errno.h>

#define LINE_MAX	1024

#ifndef DIMS
#define DIMS	3
#endif

struct cmd_opts {
	char *in_file;
};
typedef struct cmd_opts * cmd_opts_t;

#if DIMS == 2
struct vec {
	double x;
	double y;
};

struct veci {
	int x;
	int y;
};
#elif DIMS == 3
struct vec {
	double x;
	double y;
	double z;
};

struct veci {
	int x;
	int y;
	int z;
};
#endif
typedef struct vec * vec_t;
typedef struct veci * veci_t;

struct config {
	double deltaT;
	double density;
	double temperature;
	struct veci initUcell;
	int stepAvg;
	int stepEquil;
	int stepLimit;
};
typedef struct config * config_t;

#define DEBUG(format, args...) \
        do { if (MY_DEBUG) fprintf(stderr, format, args); } while(0)

/* Vector Operations */
#if DIMS == 2

#define vSet(v, sx, sy)	\
	(v).x = sx,	\
	(v).y = sy

#define vScale(v, s) \
	(v).x = s * (v).x, \
	(v).y = s * (v).y

#define vSCopy(v2, s, v1) \
	(v2).x = (s) * (v1).x,	\
	(v2).y = (s) * (v1).y

#define vSAdd(v1, v2, s3, v3)	\
	(v1).x = (v2).x + (s3) * (v3).x,	\
	(v1).y = (v2).y + (s3) * (v3).y

#define vProd(v)	((v).x * (v).y)

#define vAdd(v1, v2, v3)	\
	(v1).x = (v2).x + (v3).x, \
	(v1).y = (v2).y + (v3).y

#define vSub(v1, v2, v3)	\
	(v1).x = (v2).x - (v3).x, \
	(v1).y = (v2).y - (v3).y

#define vMul(v1, v2, v3)	\
	(v1).x = (v2).x * (v3).x, \
	(v1).y = (v2).y * (v3).y

#define vDiv(v1, v2, v3)	\
	(v1).x = (v2).x / (v3).x, \
	(v1).y = (v2).y / (v3).y

#elif DIMS == 3

#endif
void vRand (struct vec *v);

/* Thermodynamic Properties Accumulation */
#define tZero

/* Command Line Parsing */
void cmd_free_opts(struct cmd_opts *opts);
struct cmd_opts * cmd_parsing(int argc, char **argv);
int config_parsing(struct config *cfg, struct cmd_opts *opts);
