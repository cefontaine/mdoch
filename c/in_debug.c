void PrintMol(void)
{
	int n;
	DO_MOL 
#if NDIM == 2
		printf("r=(%f, %f), rv=(%f, %f), ra=(%f, %f)\n", 
			mol[n].r.x, mol[n].r.y, 
			mol[n].rv.x, mol[n].rv.y, 
			mol[n].ra.x, mol[n].ra.y);
#elif NDIM == 3
		printf("r=(%f, %f, %f), rv=(%f, %f, %f), ra=(%f, %f, %f)\n", 
			mol[n].r.x, mol[n].r.y, mol[n].r.z,
			mol[n].rv.x, mol[n].rv.y, mol[n].rv.z,
			mol[n].ra.x, mol[n].ra.y, mol[n].ra.z);
#endif
}

void TimerStart(struct timeval *start)
{
	gettimeofday(start, NULL);
}

double TimerStop(struct timeval *start)
{
	struct timeval end;
	gettimeofday(&end, NULL);

	if (end.tv_usec < start->tv_usec) {
		int nsec = (start->tv_usec - end.tv_usec) / 1000000 + 1;
		start->tv_usec -= 1000000 * nsec;
		start->tv_sec += nsec;
	}
	if (end.tv_usec - start->tv_usec > 1000000) {
		int nsec = (end.tv_usec - start->tv_usec) / 1000000;
		start->tv_usec += 1000000 * nsec;
		start->tv_sec -= nsec;
	}

	return (double) (end.tv_sec - start->tv_sec) * 1000000 
		+ (double) (end.tv_usec - start->tv_usec);
}
