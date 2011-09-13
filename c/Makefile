CC=gcc
TARGETS=allpairs2d
COMMON=common.h common.c
CFLAGS=-O -lm

all: $(TARGETS) 

allpairs2d: allpairs2d.c $(COMMON)
	$(CC) -o $@ $(CFLAGS) -DDIMS=2 common.c $<  

clean:
	rm -rf $(TARGETS)
