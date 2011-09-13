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

/* common.c */

#include "common.h"

extern float MY_VERSION;
extern int MY_DEBUG;

void fatal(const char *str)
{
	fprintf(stderr, "fatal error: %s\n", str);
	abort();
}

void * xmalloc(size_t size)
{
	register void *value = malloc(size);
	if (value == NULL)
		fatal("failed to allocate memory");
	return value;
}

static void perror2(const char *format, ...)
{
	va_list argv;
    fflush(stdout);
    fprintf(stderr, "error: ");
    va_start(argv, format);
	vfprintf(stderr, format, argv);
	va_end(argv);
    fprintf(stderr, ": %s\n", strerror(errno));
}


void usage(const char *progname)
{
	printf(
"Usage: %s [OPTION...]\n"
"\n"
"    -i                input file\n"
"    -h                print help\n"
"    -v                print version\n"
"    -d                print debug information\n"
"Report bugs to dun@logos.ic.i.u-tokyo.ac.jp\n"
"For more information: <http://mdoch.googlecode.com/>\n"
	, progname);
}

void version(void)
{
	printf(
"Version %.1f\n"
"Report bugs to dun@logos.ic.i.u-tokyo.ac.jp\n"
"For more information: <http://mdoch.googlecode.com/>\n"
	, MY_VERSION);
}

void cmd_free_opts(struct cmd_opts *opts)
{
	if (opts != NULL) {
		free(opts->in_file);
		free(opts);
	}
}

struct cmd_opts * cmd_parsing(int argc, char **argv)
{	
	int o;
	cmd_opts_t opts = NULL;

	if (argc == 1) {
		usage(argv[0]);
		exit(0);
	}
	
	opts = xmalloc(sizeof(struct cmd_opts));
	memset(opts, 0x0, sizeof(struct cmd_opts));
	while ((o = getopt(argc, argv, "dhi:v")) != -1) {
		switch (o) {
			case 'd':	/* debugging */
				MY_DEBUG = 1;
				break;
			case 'h':	/* print usage */
				cmd_free_opts(opts);
				usage(argv[0]);
				exit(0);
			case 'i':	/* input file */
				opts->in_file = strdup(optarg);
				break;
			case 'v':
				cmd_free_opts(opts);
				version();
				exit(0);
			case '?':
				cmd_free_opts(opts);
				exit(1);
			default:
				cmd_free_opts(opts);
				abort();
		}
	}
	return opts;
}

int config_parsing(struct config *cfg, struct cmd_opts *opts)
{
	char buf[LINE_MAX], *item, *value;
	const char *delimiters = " \t\n";
	FILE *fp;
	int line_no = 0;

	fp = fopen(opts->in_file, "r");
	if (fp == NULL) {
		perror(opts->in_file);
		exit(1);
	}

	DEBUG("Load configuration from %s ...\n", opts->in_file);
	memset(buf, 0x0, LINE_MAX);
	while (fgets(buf, LINE_MAX, fp) != NULL) {
		line_no++;
		item = strtok(buf, delimiters);
		value = strtok(NULL, delimiters);
		
		/* assign item/value to configurations */
		if (strcmp(item, "deltaT") == 0) {
			cfg->deltaT = atof(value);
			DEBUG(" line %d: deltaT = %f\n", line_no, cfg->deltaT);
		} else if (strcmp(item, "density") == 0) {
			cfg->density = atof(value);
			DEBUG(" line %d: density = %f\n", line_no, cfg->density);
		} else if (strcmp(item, "temperature") == 0) {
			cfg->temperature = atof(value);
			DEBUG(" line %d: temperature = %f\n", line_no, cfg->temperature);
		} else if (strcmp(item, "initUcell") == 0) {
			cfg->initUcell.x = atoi(value);
			value = strtok(NULL, delimiters);
			cfg->initUcell.y = atoi(value);
#if DIMS == 3
			value = strtok(NULL, delimiters);
			cfg->initUcell.z = atoi(value);
#endif
#if DIMS == 2
			DEBUG(" line %d: initUcell = (%d, %d) \n", 
				line_no, cfg->initUcell.x, cfg->initUcell.y);
#elif DIMS == 3
			DEBUG(" line %d: initUcell = (%d, %d, %d) \n",  line_no, 
				cfg->initUcell.x, cfg->initUcell.y, cfg->initUcell.z);
#endif
		} else if (strcmp(item, "stepAvg") == 0) {
			cfg->stepAvg = atoi(value);
			DEBUG(" line %d: stepAvg = %d\n", line_no, cfg->stepAvg);
		} else if (strcmp(item, "stepEquil") == 0) {
			cfg->stepEquil = atoi(value);
			DEBUG(" line %d: stepEquil = %d\n", line_no, cfg->stepEquil);
		} else if (strcmp(item, "stepLimit") == 0) {
			cfg->stepLimit = atoi(value);
			DEBUG(" line %d: stepLimit = %d\n", line_no, cfg->stepLimit);
		}
		memset(buf, 0x0, LINE_MAX);
	}
}

#define IADD   453806245
#define IMUL   314159269
#define MASK   2147483647
#define SCALE  0.4656612873e-9

int randSeedP = 17;

void InitRand (int randSeedI)
{
  struct timeval tv;

  if (randSeedI != 0) randSeedP = randSeedI;
  else {
    gettimeofday (&tv, 0);
    randSeedP = tv.tv_usec;
  }
}

double RandR (void)
{
  randSeedP = (randSeedP * IMUL + IADD) & MASK;
  return (randSeedP * SCALE);
}

#if DIMS == 2

void vRand (struct vec *p)
{
  double s;

  s = 2. * M_PI * RandR ();
  p->x = cos (s);
  p->y = sin (s);
}

#elif DIMS == 3

void vRand (VecR *p)
{
  real s, x, y;

  s = 2.;
  while (s > 1.) {
    x = 2. * RandR () - 1.;
    y = 2. * RandR () - 1.;
    s = Sqr (x) + Sqr (y);
  }
  p->z = 1. - 2. * s;
  s = 2. * sqrt (1. - s);
  p->x = s * x;
  p->y = s * y;
}

#endif
