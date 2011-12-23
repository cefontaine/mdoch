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

/* basic.c */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

typedef double tup[3];
typedef double nst_tup[3][3];

struct Record {
	double a;
	double b;
	double c;
};

struct nstRecord {
	struct Record a;
	struct Record b;
	struct Record c;
};

static double tv_elapsed(struct timeval *end, struct timeval *start)
{
	struct timeval res;

	if (end->tv_usec < start->tv_usec) {
		int nsec = (start->tv_usec - end->tv_usec) / 1000000 + 1;
		start->tv_usec -= 1000000 * nsec;
		start->tv_sec += nsec;
	}
	if (end->tv_usec - start->tv_usec > 1000000) {
		int nsec = (end->tv_usec - start->tv_usec) / 1000000;
		start->tv_usec += 1000000 * nsec;
		start->tv_sec -= nsec;
	}
	res.tv_sec = end->tv_sec - start->tv_sec;
	res.tv_usec = end->tv_usec - start->tv_usec;

	return (double) res.tv_sec * 1000000 + (double) res.tv_usec;
}

static double ts_elapsed(struct timespec *end, struct timespec *start)
{
	struct timespec res;

	if (end->tv_nsec < start->tv_nsec) {
		int nsec = (start->tv_nsec - end->tv_nsec) / 1000000000 + 1;
		start->tv_nsec -= 1000000000 * nsec;
		start->tv_sec += nsec;
	}
	if (end->tv_nsec - start->tv_nsec > 1000000000) {
		int nsec = (end->tv_nsec - start->tv_nsec) / 1000000000;
		start->tv_nsec += 1000000000 * nsec;
		start->tv_sec -= nsec;
	}
	res.tv_sec = end->tv_sec - start->tv_sec;
	res.tv_nsec = end->tv_nsec - start->tv_nsec;

	return (double) res.tv_sec * 1000000000 + (double) res.tv_nsec;
}

/* 
 * Evaluation of primitive types: integer, float
 */
void primitive_types(int opcnt, FILE *devnull)
{
	double asg, add, sub, mul, div;
	struct timeval tv_start, tv_end;
	int i;
	int resInt32;
	long int resInt;
	float resReal32;
	double resReal;
	
	printf("Evaluation of Primitive Types\n");
	printf("# of ops: %d, time unit: usec\n", opcnt);
	printf("op\t%17s%17s%17s%17s\n", "add", "sub", "mul", "div");
	
	/* int (int32) */
	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt32 += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt32 -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt32 *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt32 /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt32);
	printf("int%d\t%17.0f%17.0f%17.0f%17.0f\n", sizeof(resInt32) * 8, 
		add, sub, mul, div);
	
	/* long (int64) */
	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%i", resInt);
	printf("int%d\t%17.0f%17.0f%17.0f%17.0f\n", sizeof(resInt) * 8,
		add, sub, mul, div);

	/* float (real32) */
	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal32 += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal32 -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal32 *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal32);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal32 /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal32);
	printf("real%d\t%17.0f%17.0f%17.0f%17.0f\n", sizeof(resReal32) * 8,
		add, sub, mul, div);

	/* double (real64) */
	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	printf("real%d\t%17.0f%17.0f%17.0f%17.0f\n", sizeof(resReal) * 8,
		add, sub, mul, div);
}

/* 
 * Evaluation of structured types: integer, float
 */
void structured_types(int opcnt, FILE *devnull)
{
	double asg, add, sub, mul, div;
	struct timeval tv_start, tv_end;
	int i;
	printf("Evaluation of Structured Types\n");
	printf("# of ops: %d, time unit: usec\n", opcnt);
	printf("op\t%17s%17s%17s%17s\n", "add", "sub", "mul", "div");

	// Tuple
	double resTup[3];
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] += i;
		resTup[1] += i;
		resTup[2] += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] -= i;
		resTup[1] -= i;
		resTup[2] -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] *= i;
		resTup[1] *= i;
		resTup[2] *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] /= i;
		resTup[1] /= i;
		resTup[2] /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	fprintf(devnull, "%f", resTup[1]);
	fprintf(devnull, "%f", resTup[2]);
	printf("tuple\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] += i;
		resTup[1] = resTup[0] + i;
		resTup[2] = resTup[1] + i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] -= i;
		resTup[1] = resTup[0] - i;
		resTup[2] = resTup[1] - i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] *= i;
		resTup[1] = resTup[0] * i;
		resTup[2] = resTup[1] * i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] /= i;
		resTup[1] = resTup[0] / i;
		resTup[2] = resTup[1] / i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	fprintf(devnull, "%f", resTup[1]);
	fprintf(devnull, "%f", resTup[2]);
	printf("xtuple\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
	
	// Record
	struct Record resRec;

	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a += i;
		resRec.b += i;
		resRec.c += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a -= i;
		resRec.b -= i;
		resRec.c -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a *= i;
		resRec.b *= i;
		resRec.c *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a /= i;
		resRec.b /= i;
		resRec.c /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	fprintf(devnull, "%f", resRec.b);
	fprintf(devnull, "%f", resRec.c);
	printf("record\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
	
	// Nested Tuple
	double resNstTup[3][3];
	asg = add = sub = mul = div = 0;	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] += i;
		resNstTup[0][1] += i;
		resNstTup[0][2] += i;
		resNstTup[1][0] += i;
		resNstTup[1][1] += i;
		resNstTup[1][2] += i;
		resNstTup[2][0] += i;
		resNstTup[2][1] += i;
		resNstTup[2][3] += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] -= i;
		resNstTup[0][1] -= i;
		resNstTup[0][2] -= i;
		resNstTup[1][0] -= i;
		resNstTup[1][1] -= i;
		resNstTup[1][2] -= i;
		resNstTup[2][0] -= i;
		resNstTup[2][1] -= i;
		resNstTup[2][3] -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] *= i;
		resNstTup[0][1] *= i;
		resNstTup[0][2] *= i;
		resNstTup[1][0] *= i;
		resNstTup[1][1] *= i;
		resNstTup[1][2] *= i;
		resNstTup[2][0] *= i;
		resNstTup[2][1] *= i;
		resNstTup[2][3] *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] /= i;
		resNstTup[0][1] /= i;
		resNstTup[0][2] /= i;
		resNstTup[1][0] /= i;
		resNstTup[1][1] /= i;
		resNstTup[1][2] /= i;
		resNstTup[2][0] /= i;
		resNstTup[2][1] /= i;
		resNstTup[2][3] /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	fprintf(devnull, "%f", resNstTup[1][0]);
	fprintf(devnull, "%f", resNstTup[2][0]);
	printf("nTuple\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
	
	// Nested Record
	struct nstRecord resNstRec;
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a += i;
		resNstRec.a.b += i;
		resNstRec.a.c += i;
		resNstRec.b.a += i;
		resNstRec.b.b += i;
		resNstRec.b.c += i;
		resNstRec.c.a += i;
		resNstRec.c.b += i;
		resNstRec.c.c += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a -= i;
		resNstRec.a.b -= i;
		resNstRec.a.c -= i;
		resNstRec.b.a -= i;
		resNstRec.b.b -= i;
		resNstRec.b.c -= i;
		resNstRec.c.a -= i;
		resNstRec.c.b -= i;
		resNstRec.c.c -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a *= i;
		resNstRec.a.b *= i;
		resNstRec.a.c *= i;
		resNstRec.b.a *= i;
		resNstRec.b.b *= i;
		resNstRec.b.c *= i;
		resNstRec.c.a *= i;
		resNstRec.c.b *= i;
		resNstRec.c.c *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a /= i;
		resNstRec.a.b /= i;
		resNstRec.a.c /= i;
		resNstRec.b.a /= i;
		resNstRec.b.b /= i;
		resNstRec.b.c /= i;
		resNstRec.c.a /= i;
		resNstRec.c.b /= i;
		resNstRec.c.c /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	fprintf(devnull, "%f", resNstRec.b.a);
	fprintf(devnull, "%f", resNstRec.c.a);
	printf("nRecord\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a += i;
		resNstRec.a.b = resNstRec.a.a + i;
		resNstRec.a.c = resNstRec.a.b + i;
		resNstRec.b.a += i;
		resNstRec.b.b = resNstRec.b.a + i;
		resNstRec.b.c = resNstRec.b.b + i;
		resNstRec.c.a += i;
		resNstRec.c.b = resNstRec.c.a + i;
		resNstRec.c.c = resNstRec.c.b + i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a -= i;
		resNstRec.a.b = resNstRec.a.a - i;
		resNstRec.a.c = resNstRec.a.b - i;
		resNstRec.b.a -= i;
		resNstRec.b.b = resNstRec.b.a - i;
		resNstRec.b.c = resNstRec.b.b - i;
		resNstRec.c.a -= i;
		resNstRec.c.b = resNstRec.c.a - i;
		resNstRec.c.c = resNstRec.c.b - i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a *= i;
		resNstRec.a.b = resNstRec.a.a * i;
		resNstRec.a.c = resNstRec.a.b * i;
		resNstRec.b.a *= i;
		resNstRec.b.b = resNstRec.b.a * i;
		resNstRec.b.c = resNstRec.b.b * i;
		resNstRec.c.a *= i;
		resNstRec.c.b = resNstRec.c.a * i;
		resNstRec.c.c = resNstRec.c.b * i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a /= i;
		resNstRec.a.b = resNstRec.a.a / i;
		resNstRec.a.c = resNstRec.a.b / i;
		resNstRec.b.a /= i;
		resNstRec.b.b = resNstRec.b.a / i;
		resNstRec.b.c = resNstRec.b.b / i;
		resNstRec.c.a /= i;
		resNstRec.c.b = resNstRec.c.a / i;
		resNstRec.c.c = resNstRec.c.b / i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	fprintf(devnull, "%f", resNstRec.b.a);
	fprintf(devnull, "%f", resNstRec.c.a);
	printf("xnRecord\t%17.0f%17.0f%17.0f%17.0f\n", add, sub, mul, div);
}

int main(int argc, char **argv)
{
	int opcnt, i, j;
	FILE *devnull;

	if (argc < 2) {
		printf("usage: %s OPCNT\n", argv[0]);
		exit(0);
	}
	
	opcnt = atoi(argv[1]);
	devnull = fopen("/dev/null", "w");
	
//	primitive_types(opcnt, devnull);
	structured_types(opcnt, devnull);

	close(devnull);	
	return 0;
}
