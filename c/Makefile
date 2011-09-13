CC=gcc
SRC=allpairs2d.c
COMMON=common.h common.c
OBJ=$(basename $(SRC))
CFLAGS=-O -lm

all: $(OBJ) 

allpairs2d: allpairs2d.c $(COMMON)
	$(CC) $(CFLAGS) -DDIMS=2 common.c $< -o $@ 

clean:
	rm -rf *.o $(OBJ)
