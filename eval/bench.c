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

typedef double Tuple[3];
typedef double nstTuple[3][3];

typedef struct Record {
	double a;
	double b;
	double c;
} Record;

typedef struct nstRecord {
	struct Record a;
	struct Record b;
	struct Record c;
} nstRecord;

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
void primitive_types(int opcnt, size_t arrsize, FILE *devnull)
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
	printf("int%d\t%17.0f%17.0f%17.0f%17.0f\n", 
		sizeof(resInt) * 8, add, sub, mul, div);

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
	printf("real%d\t%17.0f%17.0f%17.0f%17.0f\n", 
		sizeof(resReal32) * 8, add, sub, mul, div);

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
	printf("real%d\t%17.0f%17.0f%17.0f%17.0f\n", 
		sizeof(resReal) * 8, add, sub, mul, div);
}

void parallel_types(int opcnt, size_t arrsize, FILE *devnull)
{
	double asg, add, sub, mul, div;
	struct timeval tv_start, tv_end;
	double *arr, res;
	int i;

	/* array */
	arr = malloc(arrsize * sizeof(double));
	if (arr == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arr[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arr[i] += arr[(i+1) % opcnt];
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++)
		arr[i] -= arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++)
		arr[i] *= arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++)
		res = arr[i] / arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	printf("array\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arr);
}


/* 
 * Evaluation of array of structured types
 */
void array_with_types_r(int opcnt, size_t arrsize, FILE *devnull)
{
	double asg, add, sub, mul, div;
	struct timeval tv_start, tv_end;
	double resTup[3];
	double resNstTup[3][3];
	struct Record resRec;
	int *arrInt;
	int resInt;
	double *arrReal;
	double  resReal;
	Tuple *arrTup;
	nstTuple *arrNstTup;
	Record *arrRec;
	nstRecord *arrNstRec;
	nstRecord resNstRec;
	int i;

	printf("Evaluation of Array with Types (Read Only)\n");
	printf("# of ops: %d, time unit: usec\n", opcnt);
	printf("op\t\t%17s%17s%17s%17s%17s\n", "asg", "add", "sub", "mul", "div");

	// Int
	arrInt = (int *) malloc(arrsize * sizeof(int));
	if (arrInt == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt += arrInt[i];
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt -= arrInt[i];
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt *= arrInt[i];
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	arrInt[0] = 1;
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resInt /= arrInt[i];
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	// introduce dependency
	fprintf(devnull, "%f", resInt);
	printf("intArr\t\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrInt);
	
	// Real
	arrReal = (double *) malloc(arrsize * sizeof(double));
	if (arrReal == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal += arrReal[i];
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal -= arrReal[i];
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal *= arrReal[i];
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	arrReal[0] = 1;
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) resReal /= arrReal[i];
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	// introduce dependency
	fprintf(devnull, "%f", resReal);
	printf("realArr\t\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrReal);

	// Tuple
	arrTup = (Tuple *) malloc(arrsize * sizeof(Tuple));
	if (arrTup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] = i;
		arrTup[i][1] = i;
		arrTup[i][2] = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] += arrTup[i][0];
		resTup[1] += arrTup[i][1];
		resTup[2] += arrTup[i][2];
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] -= arrTup[i][0];
		resTup[1] -= arrTup[i][1];
		resTup[2] -= arrTup[i][2];
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] *= arrTup[i][0];
		resTup[1] *= arrTup[i][1];
		resTup[2] *= arrTup[i][2];
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resTup[0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resTup[0] /= arrTup[i][0];
		resTup[1] /= arrTup[i][1];
		resTup[2] /= arrTup[i][2];
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	// introduce dependency
	fprintf(devnull, "%f%f%f", resTup[0], resTup[1], resTup[2]);
	printf("tupleArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrTup);
	
	// Record Array
	arrRec = (Record *) malloc(arrsize * sizeof(Record));
	if (arrRec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a = i;
		arrRec[i].b = i;
		arrRec[i].c = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a += arrRec[i].a;
		resRec.b += arrRec[i].b;
		resRec.c += arrRec[i].c;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", arrRec[0].a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a -= arrRec[i].a;
		resRec.b -= arrRec[i].b;
		resRec.c -= arrRec[i].c;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a *= arrRec[i].a;
		resRec.b *= arrRec[i].b;
		resRec.c *= arrRec[i].c;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resRec.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resRec.a /= arrRec[i].a;
		resRec.b /= arrRec[i].b;
		resRec.c /= arrRec[i].c;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", resRec.a, resRec.b, resRec.c);
	printf("recordArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrRec);
	
	// Nested Tuple
	arrNstTup = (nstTuple *) malloc(arrsize * sizeof(nstTuple));
	if (arrNstTup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] = i;
		arrNstTup[i][0][1] = i;
		arrNstTup[i][0][2] = i;
		arrNstTup[i][1][0] = i;
		arrNstTup[i][1][1] = i;
		arrNstTup[i][1][2] = i;
		arrNstTup[i][2][0] = i;
		arrNstTup[i][2][1] = i;
		arrNstTup[i][2][2] = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] += arrNstTup[i][0][0];
		resNstTup[0][1] += arrNstTup[i][0][1];
		resNstTup[0][2] += arrNstTup[i][0][2];
		resNstTup[1][0] += arrNstTup[i][1][0];
		resNstTup[1][1] += arrNstTup[i][1][1];
		resNstTup[1][2] += arrNstTup[i][1][2];
		resNstTup[2][0] += arrNstTup[i][2][0];
		resNstTup[2][1] += arrNstTup[i][2][1];
		resNstTup[2][1] += arrNstTup[i][2][2];
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] -= arrNstTup[i][0][0];
		resNstTup[0][1] -= arrNstTup[i][0][1];
		resNstTup[0][2] -= arrNstTup[i][0][2];
		resNstTup[1][0] -= arrNstTup[i][1][0];
		resNstTup[1][1] -= arrNstTup[i][1][1];
		resNstTup[1][2] -= arrNstTup[i][1][2];
		resNstTup[2][0] -= arrNstTup[i][2][0];
		resNstTup[2][1] -= arrNstTup[i][2][1];
		resNstTup[2][1] -= arrNstTup[i][2][2];
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] *= arrNstTup[i][0][0];
		resNstTup[0][1] *= arrNstTup[i][0][1];
		resNstTup[0][2] *= arrNstTup[i][0][2];
		resNstTup[1][0] *= arrNstTup[i][1][0];
		resNstTup[1][1] *= arrNstTup[i][1][1];
		resNstTup[1][2] *= arrNstTup[i][1][2];
		resNstTup[2][0] *= arrNstTup[i][2][0];
		resNstTup[2][1] *= arrNstTup[i][2][1];
		resNstTup[2][1] *= arrNstTup[i][2][2];
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstTup[0][0]);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstTup[0][0] /= arrNstTup[i][0][0];
		resNstTup[0][1] /= arrNstTup[i][0][1];
		resNstTup[0][2] /= arrNstTup[i][0][2];
		resNstTup[1][0] /= arrNstTup[i][1][0];
		resNstTup[1][1] /= arrNstTup[i][1][1];
		resNstTup[1][2] /= arrNstTup[i][1][2];
		resNstTup[2][0] /= arrNstTup[i][2][0];
		resNstTup[2][1] /= arrNstTup[i][2][1];
		resNstTup[2][1] /= arrNstTup[i][2][2];
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", resNstTup[0][0], resNstTup[1][0],
		resNstTup[2][0]);
	printf("nTupleArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrNstTup);
	
	// Nested Record
	arrNstRec = (nstRecord *) malloc(arrsize * sizeof(nstRecord));
	if (arrNstRec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a = i;
		arrNstRec[i].a.b = i;
		arrNstRec[i].a.c = i;
		arrNstRec[i].b.a = i;
		arrNstRec[i].b.b = i;
		arrNstRec[i].b.c = i;
		arrNstRec[i].c.a = i;
		arrNstRec[i].c.b = i;
		arrNstRec[i].c.c = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a += arrNstRec[i].a.a;
		resNstRec.a.b += arrNstRec[i].a.b;
		resNstRec.a.c += arrNstRec[i].a.c;
		resNstRec.b.a += arrNstRec[i].b.a;
		resNstRec.b.b += arrNstRec[i].b.b;
		resNstRec.b.c += arrNstRec[i].b.c;
		resNstRec.c.a += arrNstRec[i].c.a;
		resNstRec.c.b += arrNstRec[i].c.b;
		resNstRec.c.c += arrNstRec[i].c.c;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a -= arrNstRec[i].a.a;
		resNstRec.a.b -= arrNstRec[i].a.b;
		resNstRec.a.c -= arrNstRec[i].a.c;
		resNstRec.b.a -= arrNstRec[i].b.a;
		resNstRec.b.b -= arrNstRec[i].b.b;
		resNstRec.b.c -= arrNstRec[i].b.c;
		resNstRec.c.a -= arrNstRec[i].c.a;
		resNstRec.c.b -= arrNstRec[i].c.b;
		resNstRec.c.c -= arrNstRec[i].c.c;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a *= arrNstRec[i].a.a;
		resNstRec.a.b *= arrNstRec[i].a.b;
		resNstRec.a.c *= arrNstRec[i].a.c;
		resNstRec.b.a *= arrNstRec[i].b.a;
		resNstRec.b.b *= arrNstRec[i].b.b;
		resNstRec.b.c *= arrNstRec[i].b.c;
		resNstRec.c.a *= arrNstRec[i].c.a;
		resNstRec.c.b *= arrNstRec[i].c.b;
		resNstRec.c.c *= arrNstRec[i].c.c;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resNstRec.a.a);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		resNstRec.a.a /= arrNstRec[i].a.a;
		resNstRec.a.b /= arrNstRec[i].a.b;
		resNstRec.a.c /= arrNstRec[i].a.c;
		resNstRec.b.a /= arrNstRec[i].b.a;
		resNstRec.b.b /= arrNstRec[i].b.b;
		resNstRec.b.c /= arrNstRec[i].b.c;
		resNstRec.c.a /= arrNstRec[i].c.a;
		resNstRec.c.b /= arrNstRec[i].c.b;
		resNstRec.c.c /= arrNstRec[i].c.c;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", resNstRec.a.a, resNstRec.b.a, resNstRec.c.a);
	printf("nRecordArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arrNstRec);
}

void array_with_types_rw(int opcnt, size_t arrsize, FILE *devnull)
{
	double asg, add, sub, mul, div;
	struct timeval tv_start, tv_end;
	double resTup[3];
	double resNstTup[3][3];
	struct Record resRec;
	int *arrInt;
	int resInt;
	double *arrReal;
	double  resReal;
	Tuple *arrTup;
	nstTuple *arrNstTup;
	Record *arrRec;
	nstRecord *arrNstRec;
	nstRecord resNstRec;
	int i;

	printf("Evaluation of Array with Types (Read/Write)\n");
	printf("# of ops: %d, time unit: usec\n", opcnt);
	printf("op\t\t%17s%17s%17s%17s%17s\n", "asg", "add", "sub", "mul", "div");

	// Int
	arrInt = (int *) malloc(arrsize * sizeof(int));
	if (arrInt == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resInt);
	
	arrInt[0] = 1;
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrInt[i] /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("intArr\t\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrInt);
	
	// Real
	arrReal = (double *) malloc(arrsize * sizeof(double));
	if (arrReal == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] += i;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] -= i;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] *= i;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", resReal);
	
	arrReal[0] = 1;
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) arrReal[i] /= i;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("realArr\t\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrReal);

	// Tuple
	arrTup = (Tuple *) malloc(arrsize * sizeof(Tuple));
	if (arrTup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] = i;
		arrTup[i][1] = i;
		arrTup[i][2] = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] += i;
		arrTup[i][1] += i;
		arrTup[i][2] += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] -= i;
		arrTup[i][1] -= i;
		arrTup[i][2] -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] *= i;
		arrTup[i][1] *= i;
		arrTup[i][2] *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrTup[i][0] /= i;
		arrTup[i][1] /= i;
		arrTup[i][2] /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("tupleArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrTup);
	
	// Record Array
	arrRec = (Record *) malloc(arrsize * sizeof(Record));
	if (arrRec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a = i;
		arrRec[i].b = i;
		arrRec[i].c = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a += i;
		arrRec[i].b += i;
		arrRec[i].c += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a -= i;
		arrRec[i].b -= i;
		arrRec[i].c -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a *= i;
		arrRec[i].b *= i;
		arrRec[i].c *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrRec[i].a /= i;
		arrRec[i].b /= i;
		arrRec[i].c /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("recordArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrRec);
	
	// Nested Tuple
	arrNstTup = (nstTuple *) malloc(arrsize * sizeof(nstTuple));
	if (arrNstTup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] = i;
		arrNstTup[i][0][1] = i;
		arrNstTup[i][0][2] = i;
		arrNstTup[i][1][0] = i;
		arrNstTup[i][1][1] = i;
		arrNstTup[i][1][2] = i;
		arrNstTup[i][2][0] = i;
		arrNstTup[i][2][1] = i;
		arrNstTup[i][2][2] = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] += i;
		arrNstTup[i][0][1] += i;
		arrNstTup[i][0][2] += i;
		arrNstTup[i][1][0] += i;
		arrNstTup[i][1][1] += i;
		arrNstTup[i][1][2] += i;
		arrNstTup[i][2][0] += i;
		arrNstTup[i][2][1] += i;
		arrNstTup[i][2][2] += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] -= i;
		arrNstTup[i][0][1] -= i;
		arrNstTup[i][0][2] -= i;
		arrNstTup[i][1][0] -= i;
		arrNstTup[i][1][1] -= i;
		arrNstTup[i][1][2] -= i;
		arrNstTup[i][2][0] -= i;
		arrNstTup[i][2][1] -= i;
		arrNstTup[i][2][2] -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] *= i;
		arrNstTup[i][0][1] *= i;
		arrNstTup[i][0][2] *= i;
		arrNstTup[i][1][0] *= i;
		arrNstTup[i][1][1] *= i;
		arrNstTup[i][1][2] *= i;
		arrNstTup[i][2][0] *= i;
		arrNstTup[i][2][1] *= i;
		arrNstTup[i][2][2] *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstTup[i][0][0] /= i;
		arrNstTup[i][0][1] /= i;
		arrNstTup[i][0][2] /= i;
		arrNstTup[i][1][0] /= i;
		arrNstTup[i][1][1] /= i;
		arrNstTup[i][1][2] /= i;
		arrNstTup[i][2][0] /= i;
		arrNstTup[i][2][1] /= i;
		arrNstTup[i][2][2] /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("nTupleArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", asg, add, sub, mul, div);
	free(arrNstTup);
	
	// Nested Record
	arrNstRec = (nstRecord *) malloc(arrsize * sizeof(nstRecord));
	if (arrNstRec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a = i;
		arrNstRec[i].a.b = i;
		arrNstRec[i].a.c = i;
		arrNstRec[i].b.a = i;
		arrNstRec[i].b.b = i;
		arrNstRec[i].b.c = i;
		arrNstRec[i].c.a = i;
		arrNstRec[i].c.b = i;
		arrNstRec[i].c.c = i;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a += i;
		arrNstRec[i].a.b += i;
		arrNstRec[i].a.c += i;
		arrNstRec[i].b.a += i;
		arrNstRec[i].b.b += i;
		arrNstRec[i].b.c += i;
		arrNstRec[i].c.a += i;
		arrNstRec[i].c.b += i;
		arrNstRec[i].c.c += i;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a -= i;
		arrNstRec[i].a.b -= i;
		arrNstRec[i].a.c -= i;
		arrNstRec[i].b.a -= i;
		arrNstRec[i].b.b -= i;
		arrNstRec[i].b.c -= i;
		arrNstRec[i].c.a -= i;
		arrNstRec[i].c.b -= i;
		arrNstRec[i].c.c -= i;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a *= i;
		arrNstRec[i].a.b *= i;
		arrNstRec[i].a.c *= i;
		arrNstRec[i].b.a *= i;
		arrNstRec[i].b.b *= i;
		arrNstRec[i].b.c *= i;
		arrNstRec[i].c.a *= i;
		arrNstRec[i].c.b *= i;
		arrNstRec[i].c.c *= i;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	
	gettimeofday(&tv_start, NULL);
	for (i = 1; i <= opcnt; i++) {
		arrNstRec[i].a.a /= i;
		arrNstRec[i].a.b /= i;
		arrNstRec[i].a.c /= i;
		arrNstRec[i].b.a /= i;
		arrNstRec[i].b.b /= i;
		arrNstRec[i].b.c /= i;
		arrNstRec[i].c.a /= i;
		arrNstRec[i].c.b /= i;
		arrNstRec[i].c.c /= i;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	printf("nRecordArr\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arrNstRec);
}

int main(int argc, char **argv)
{
	int opcnt;
	FILE *devnull;
	size_t arrsize;

	if (argc < 2) {
		printf("usage: %s OPCNT\n", argv[0]);
		exit(0);
	}
	
	opcnt = atoi(argv[1]);
	arrsize = opcnt + 1;	// index starts from 1
	devnull = fopen("/dev/null", "w");
	
	//primitive_types(opcnt, arrsize, devnull);
	array_with_types_r(opcnt, arrsize, devnull);
	array_with_types_rw(opcnt, arrsize, devnull);
	//parallel_types(opcnt, arrsize, devnull);

	close(devnull);	
	return 0;
}
