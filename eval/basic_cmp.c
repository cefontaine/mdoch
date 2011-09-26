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

struct rec {
	double x;
	double y;
	double z;
};

struct nst_rec {
	struct rec *x;
	struct rec *y;
	struct rec *z;
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

int main(int argc, char **argv)
{
	int opcnt, i, j;
	struct timeval tv_start, tv_end;
	double asg, add, sub, mul, div;
	double res, res_tup[3], res_nst_tup[3][3];
	double *arr, **arr_tup, ***arr_nst_tup;
	struct rec res_rec, *arr_rec;
	struct nst_rec res_nst_rec, *arr_nst_rec;
	FILE *devnull;

	if (argc < 2) {
		printf("usage: %s ARRSIZE\n", argv[0]);
		exit(0);
	}
	
	opcnt = atoi(argv[1]);
	devnull = fopen("/dev/null", "w");

	printf("# of ops: %d, time unit: usec\n", opcnt);
	printf("op\t%17s%17s%17s%17s%17s\n", "asg", "add", "sub", "mul", "div");

	/* basic double operation */
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);	/* force compiler not to optimize */
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = i + 1.0;
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = i - 2.0;
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = i * 3.0;
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = i / 4.0;
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	printf("float\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	
	/* array */
	arr = malloc(opcnt * sizeof(double));
	if (arr == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}

	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		arr[i] = i;
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = arr[i] + arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = arr[i] - arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = arr[i] * arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++)
		res = arr[i] / arr[(i+1) % opcnt];
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f", res);
	
	printf("array\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arr);
	
	/* 1D-array vs. struct */
	arr_tup = (double **) malloc(opcnt * sizeof(double *));
	if (arr_tup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	for (i = 0; i < opcnt; i++) {
		arr_tup[i] = (double *) malloc(sizeof(double) * 3);
		if (arr_tup[i] == NULL) {
			fprintf(stderr, "failed to allocate memory\n");
			exit(1);
		}
	}
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		arr_tup[i][0] = 1.0;
		arr_tup[i][1] = 1.0;
		arr_tup[i][2] = 1.0;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", arr_tup[0][0], arr_tup[0][1], arr_tup[0][2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_tup[0] = arr_tup[i][0] + arr_tup[(i+1) % opcnt][0];
		res_tup[1] = arr_tup[i][1] + arr_tup[(i+1) % opcnt][1];
		res_tup[2] = arr_tup[i][2] + arr_tup[(i+1) % opcnt][2];
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_tup[0], res_tup[1], res_tup[2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_tup[0] = arr_tup[i][0] - arr_tup[(i+1) % opcnt][0];
		res_tup[1] = arr_tup[i][1] - arr_tup[(i+1) % opcnt][1];
		res_tup[2] = arr_tup[i][2] - arr_tup[(i+1) % opcnt][2];
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_tup[0], res_tup[1], res_tup[2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_tup[0] = arr_tup[i][0] * arr_tup[(i+1) % opcnt][0];
		res_tup[1] = arr_tup[i][1] * arr_tup[(i+1) % opcnt][1];
		res_tup[2] = arr_tup[i][2] * arr_tup[(i+1) % opcnt][2];
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_tup[0], res_tup[1], res_tup[2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_tup[0] = arr_tup[i][0] / arr_tup[(i+1) % opcnt][0];
		res_tup[1] = arr_tup[i][1] / arr_tup[(i+1) % opcnt][1];
		res_tup[2] = arr_tup[i][2] / arr_tup[(i+1) % opcnt][2];
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_tup[0], res_tup[1], res_tup[2]);
	
	printf("1D-tup\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arr_tup);

	arr_rec = (struct rec *) malloc(opcnt * sizeof(struct rec));
	if (arr_rec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		arr_rec[i].x = 1.0;
		arr_rec[i].y = 1.0;
		arr_rec[i].z = 1.0;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", arr_rec[0].x, arr_rec[0].y, arr_rec[0].z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_rec.x = arr_rec[i].x + arr_rec[(i+1) % opcnt].x;
		res_rec.y = arr_rec[i].y + arr_rec[(i+1) % opcnt].y;
		res_rec.z = arr_rec[i].z + arr_rec[(i+1) % opcnt].z;
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_rec.x, res_rec.y, res_rec.z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_rec.x = arr_rec[i].x - arr_rec[(i+1) % opcnt].x;
		res_rec.y = arr_rec[i].y - arr_rec[(i+1) % opcnt].y;
		res_rec.z = arr_rec[i].z - arr_rec[(i+1) % opcnt].z;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_rec.x, res_rec.y, res_rec.z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_rec.x = arr_rec[i].x * arr_rec[(i+1) % opcnt].x;
		res_rec.y = arr_rec[i].y * arr_rec[(i+1) % opcnt].y;
		res_rec.z = arr_rec[i].z * arr_rec[(i+1) % opcnt].z;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_rec.x, res_rec.y, res_rec.z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_rec.x = arr_rec[i].x / arr_rec[(i+1) % opcnt].x;
		res_rec.y = arr_rec[i].y / arr_rec[(i+1) % opcnt].y;
		res_rec.z = arr_rec[i].z / arr_rec[(i+1) % opcnt].z;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", res_rec.x, res_rec.y, res_rec.z);
	
	printf("1D-rec\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);
	free(arr_rec);
	
	/* 2D-array vs. struct */
	arr_nst_tup = (double ***) malloc(opcnt * sizeof(double **));
	if (arr_nst_tup == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	for (i = 0; i < opcnt; i++) {
		arr_nst_tup[i] = (double **) malloc(sizeof(double *) * 3);
		if (arr_nst_tup[i] == NULL) {
			fprintf(stderr, "failed to allocate memory\n");
			exit(1);
		}
		for (j = 0; j < 3; j++) {
			arr_nst_tup[i][j] = (double *) malloc(sizeof(double) * 3);
			if (arr_nst_tup[i][j] == NULL) {
				fprintf(stderr, "failed to allocate memory\n");
				exit(1);
			}
		}
	}
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++) {
			arr_nst_tup[i][j][0] = 1.0;
			arr_nst_tup[i][j][1] = 1.0;
			arr_nst_tup[i][j][2] = 1.0;
		}
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		arr_nst_tup[0][0][0], arr_nst_tup[0][0][1], arr_nst_tup[0][0][2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++) {
			res_nst_tup[j][0] = arr_nst_tup[i][j][0] 
				+ arr_nst_tup[(i+1) % opcnt][j][0];
			res_nst_tup[j][1] = arr_nst_tup[i][j][1] 
				+ arr_nst_tup[(i+1) % opcnt][j][1];
			res_nst_tup[j][2] = arr_nst_tup[i][j][2] 
				+ arr_nst_tup[(i+1) % opcnt][j][2];
		}
	}
	gettimeofday(&tv_end, NULL);
	add = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_tup[0][0], res_nst_tup[0][1], res_nst_tup[0][2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++) {
			res_nst_tup[j][0] = arr_nst_tup[i][j][0] 
				- arr_nst_tup[(i+1) % opcnt][j][0];
			res_nst_tup[j][1] = arr_nst_tup[i][j][1] 
				- arr_nst_tup[(i+1) % opcnt][j][1];
			res_nst_tup[j][2] = arr_nst_tup[i][j][2] 
				- arr_nst_tup[(i+1) % opcnt][j][2];
		}
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_tup[0][0], res_nst_tup[0][1], res_nst_tup[0][2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++) {
			res_nst_tup[j][0] = arr_nst_tup[i][j][0] 
				* arr_nst_tup[(i+1) % opcnt][j][0];
			res_nst_tup[j][1] = arr_nst_tup[i][j][1] 
				* arr_nst_tup[(i+1) % opcnt][j][1];
			res_nst_tup[j][2] = arr_nst_tup[i][j][2] 
				* arr_nst_tup[(i+1) % opcnt][j][2];
		}
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_tup[0][0], res_nst_tup[0][1], res_nst_tup[0][2]);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++) {
			res_nst_tup[j][0] = arr_nst_tup[i][j][0] 
				/ arr_nst_tup[(i+1) % opcnt][j][0];
			res_nst_tup[j][1] = arr_nst_tup[i][j][1] 
				/ arr_nst_tup[(i+1) % opcnt][j][1];
			res_nst_tup[j][2] = arr_nst_tup[i][j][2] 
				/ arr_nst_tup[(i+1) % opcnt][j][2];
		}
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_tup[0][0], res_nst_tup[0][1], res_nst_tup[0][2]);
	
	printf("2D-tup\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);

	for (i = 0; i < opcnt; i++) {
		for (j = 0; j < 3; j++)
			free(arr_nst_tup[i][j]);
		free(arr_nst_tup[i]);
	}
	free(arr_nst_tup);
	
	arr_nst_rec = (struct nst_rec *) 
		malloc(opcnt * sizeof(struct nst_rec));
	if (arr_nst_rec == NULL) {
		fprintf(stderr, "failed to allocate memory\n");
		exit(1);
	}
	for (i = 0; i < opcnt; i++) {
		arr_nst_rec[i].x = (struct rec *) malloc(sizeof(struct rec));
		arr_nst_rec[i].y = (struct rec *) malloc(sizeof(struct rec));
		arr_nst_rec[i].z = (struct rec *) malloc(sizeof(struct rec));
		if (arr_nst_rec[i].x == NULL || arr_nst_rec[i].y == NULL ||
			arr_nst_rec[i].z == NULL) {
			fprintf(stderr, "failed to allocate memory\n");
			exit(1);
		}
	}
	struct rec x, y, z;
	res_nst_rec.x = &x;
	res_nst_rec.y = &y;
	res_nst_rec.z = &z;
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		(arr_nst_rec[i].x)->x = 1.0;
		(arr_nst_rec[i].x)->y = 1.0;
		(arr_nst_rec[i].x)->z = 1.0;
		
		(arr_nst_rec[i].y)->x = 1.0;
		(arr_nst_rec[i].y)->y = 1.0;
		(arr_nst_rec[i].y)->z = 1.0;
		
		(arr_nst_rec[i].z)->x = 1.0;
		(arr_nst_rec[i].z)->y = 1.0;
		(arr_nst_rec[i].z)->z = 1.0;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		arr_nst_rec[0].x->x, arr_nst_rec[0].x->y, arr_nst_rec[0].x->z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_nst_rec.x->x = (arr_nst_rec[i].x)->x 
			+ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.x->y = (arr_nst_rec[i].x)->y 
			+ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.x->z = (arr_nst_rec[i].x)->z 
			+ (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.y->x = (arr_nst_rec[i].x)->x 
			+ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.y->y = (arr_nst_rec[i].x)->y 
			+ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.y->z = (arr_nst_rec[i].x)->z 
			+ (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.z->x = (arr_nst_rec[i].x)->x 
			+ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.z->y = (arr_nst_rec[i].x)->y 
			+ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.z->z = (arr_nst_rec[i].x)->z 
			+ (arr_nst_rec[(i+1) % opcnt].x)->z;
	}
	gettimeofday(&tv_end, NULL);
	asg = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_rec.x->x, res_nst_rec.x->y, res_nst_rec.x->z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_nst_rec.x->x = (arr_nst_rec[i].x)->x 
			- (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.x->y = (arr_nst_rec[i].x)->y 
			- (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.x->z = (arr_nst_rec[i].x)->z 
			- (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.y->x = (arr_nst_rec[i].x)->x 
			- (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.y->y = (arr_nst_rec[i].x)->y 
			- (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.y->z = (arr_nst_rec[i].x)->z 
			- (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.z->x = (arr_nst_rec[i].x)->x 
			- (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.z->y = (arr_nst_rec[i].x)->y 
			- (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.z->z = (arr_nst_rec[i].x)->z 
			- (arr_nst_rec[(i+1) % opcnt].x)->z;
	}
	gettimeofday(&tv_end, NULL);
	sub = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_rec.x->x, res_nst_rec.x->y, res_nst_rec.x->z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_nst_rec.x->x = (arr_nst_rec[i].x)->x 
			* (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.x->y = (arr_nst_rec[i].x)->y 
			* (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.x->z = (arr_nst_rec[i].x)->z 
			* (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.y->x = (arr_nst_rec[i].x)->x 
			* (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.y->y = (arr_nst_rec[i].x)->y 
			* (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.y->z = (arr_nst_rec[i].x)->z 
			* (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.z->x = (arr_nst_rec[i].x)->x 
			* (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.z->y = (arr_nst_rec[i].x)->y 
			* (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.z->z = (arr_nst_rec[i].x)->z 
			* (arr_nst_rec[(i+1) % opcnt].x)->z;
	}
	gettimeofday(&tv_end, NULL);
	mul = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_rec.x->x, res_nst_rec.x->y, res_nst_rec.x->z);
	
	gettimeofday(&tv_start, NULL);
	for	(i = 0; i < opcnt; i++) {
		res_nst_rec.x->x = (arr_nst_rec[i].x)->x 
			/ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.x->y = (arr_nst_rec[i].x)->y 
			/ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.x->z = (arr_nst_rec[i].x)->z 
			/ (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.y->x = (arr_nst_rec[i].x)->x 
			/ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.y->y = (arr_nst_rec[i].x)->y 
			/ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.y->z = (arr_nst_rec[i].x)->z 
			/ (arr_nst_rec[(i+1) % opcnt].x)->z;
		
		res_nst_rec.z->x = (arr_nst_rec[i].x)->x 
			/ (arr_nst_rec[(i+1) % opcnt].x)->x;
		res_nst_rec.z->y = (arr_nst_rec[i].x)->y 
			/ (arr_nst_rec[(i+1) % opcnt].x)->y;
		res_nst_rec.z->z = (arr_nst_rec[i].x)->z 
			/ (arr_nst_rec[(i+1) % opcnt].x)->z;
	}
	gettimeofday(&tv_end, NULL);
	div = tv_elapsed(&tv_end, &tv_start);
	fprintf(devnull, "%f%f%f", 
		res_nst_rec.x->x, res_nst_rec.x->y, res_nst_rec.x->z);

	printf("2D-rec\t%17.0f%17.0f%17.0f%17.0f%17.0f\n", 
		asg, add, sub, mul, div);

	for (i = 0; i < opcnt; i++) {
		free(arr_nst_rec[i].x);
		free(arr_nst_rec[i].y);
		free(arr_nst_rec[i].z);
	}
	free(arr_nst_rec);

	close(devnull);	
	return 0;
}
