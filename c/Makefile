CC=gcc
SRC=allpairs2d.c
OBJ=$(basename $(SRC))
CFLAGS=-O

all: $(OBJ)

%: %.c
	$(CC) $(CFLAGS) -o $* $?
