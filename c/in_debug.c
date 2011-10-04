void PrintMol(void)
{
	int n;
	DO_MOL 
#if NDIM == 2
		printf("r=(%f, %f), rv=(%f, %f), ra=(%f, %f)\n", 
			mol[n].r.x, mol[n].r.y, 
			mol[n].rv.x, mol[n].rv.y, 
			mol[n].ra.x, mol[n].ra.y);
#elif NIDM == 3
		printf("r=(%f, %f, %f), rv=(%f, %f, %f), ra=(%f, %f, %f)\n", 
			mol[n].r.x, mol[n].r.y, mol[n].r.z,
			mol[n].rv.x, mol[n].rv.y, mol[n].rv.z,
			mol[n].ra.x, mol[n].ra.y, mol[n].ra.z);
#endif
}
