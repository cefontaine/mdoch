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

/* allpairs2d.c */

#define DIMS	2	/* Our system is 2-dimensional */

#include "common.h"

float MY_VERSION = 0.1;
int MY_DEBUG = 0;

struct atom {
	struct vec r;	/* coordinates */
	struct vec rv;	/* velocity */
	struct vec ra;	/* acceleration */
};

struct md {
	double rCut;		/* distance threshold */
	struct vec region;
	unsigned int N;		/* # of atoms */
	double initVel;		/* initial velocity */
	struct atom *mol;	/* array of atoms */
	struct vec velSum;	/* velocity sum */
	unsigned int stepCount;
	
	/* variables from config */
	double deltaT;
	double density;
	double temperature;
	struct veci initUcell;
	int stepAvg;
	int stepEquil;
	int stepLimit;
};

void init(struct md *md, struct config *cfg)
{
	DEBUG("Init: system dimensionality = %d\n", DIMS);
	md->deltaT = cfg->deltaT;
	md->density = cfg->density;
	md->temperature = cfg->temperature;
	md->initUcell = cfg->initUcell;
	md->stepAvg = cfg->stepAvg;
	md->stepEquil = cfg->stepEquil;
	md->stepLimit = cfg->stepLimit;

	md->rCut = pow(2., 1./6.);
	vSCopy(md->region, 1./sqrt(md->density), md->initUcell);
	md->N = vProd(md->initUcell);
	md->initVel = sqrt(DIMS * (1. - 1. / md->N) * md->temperature);
	
	md->mol = (struct atom *) (intptr_t) xmalloc(
		md->N * sizeof(struct atom));
	md->stepCount = 0;

	/* Initial coordinates */
	struct vec c, gap;
	unsigned int nx, ny, n;
	vDiv(gap, md->region, md->initUcell);
	for (ny = 0; ny < md->initUcell.y; ny++) {
		for (nx = 0; nx < md->initUcell.x; nx++) {
			vSet(c, nx + 0.5, ny + 0.5);	/* center of box of lattice */
			vMul(c, c, gap);
			vSAdd(c, c, -0.5, md->region);
			md->mol[n].r = c;
			n++;
		}
	}

	/* Initial velocities */
	vSet(md->velSum, 0, 0);
	for (n = 0; n < md->N; n++) {
	}

}

int main(int argc, char **argv)
{
	struct config cfg;
	struct md md;
	int steps = 0;
	int steps_limit = 10;
	
	cmd_opts_t opts = cmd_parsing(argc, argv);
	config_parsing(&cfg, opts);
	cmd_free_opts(opts);
	
	init(&md, &cfg);	

	while (steps < steps_limit) {
		printf("Conduct step %d\n", steps);
		steps++;
	}
	
	return 0;
}
