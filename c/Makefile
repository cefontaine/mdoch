CC=gcc
TARGETS=allpairs2d veldist cellsub nebrlist cellspc nebrlistpc trajsep \
	thermosoft thermolj fmm
DEPENDS=in_errexit.c inmddefs.h in_proto.h in_rand.c in_vdefs.h \
	in_namelist.h in_namelist.c in_debug.h in_debug.c
CFLAGS=-O3 -lm

all: $(TARGETS) 

%: %.c
	$(CC) -o $@ $< $(CFLAGS) 

clean:
	rm -rf $(TARGETS)
