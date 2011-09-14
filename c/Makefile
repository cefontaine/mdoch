CC=gcc
TARGETS=allpairs2d
DEPENDS=in_errexit.c inmddefs.h in_proto.h in_rand.c in_vdefs.h in_namelist.h in_namelist.c
CFLAGS=-O -lm

all: $(TARGETS) 

%: %.c
	$(CC) -o $@ $< $(CFLAGS) 

clean:
	rm -rf $(TARGETS)
