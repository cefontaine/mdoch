CC=gcc
CHPL=chpl
CFLAGS=-O3 -lm
CHFLAGS=--fast
TARGETS=bench_chpl bench_c

all: $(TARGETS)

bench_c: bench.c 
	$(CC) -o $@ $< $(CFLAGS)

bench_chpl: bench.chpl
	$(CHPL) -o $@ $< $(CHFLAGS)

clean:
	rm -f $(TARGETS)
