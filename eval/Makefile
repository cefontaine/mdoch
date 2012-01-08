CC=gcc
CHPL=chpl
CFLAGS=-O3 -lm
CHFLAGS=--fast
TARGETS=bench bench_c

all: $(TARGETS)

bench: bench.chpl
	$(CHPL) -o $@ $< $(CHFLAGS) --codegen --savec bench_src

bench_c: bench.c 
	$(CC) -o $@ $< $(CFLAGS)

clean:
	rm -f $(TARGETS)
