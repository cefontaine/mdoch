CC=gcc
CHPL=chpl
CFLAGS=-O3 -lm
CHFLAGS=--fast
TARGETS=array loop allpairs2d

all: $(TARGETS) basic_c basic_chpl

%: %.chpl
	$(CHPL) -o $@ $< $(CHFLAGS)

basic_c: basic.c 
	$(CC) -o $@ $< $(CFLAGS)

basic_chpl: basic.chpl
	$(CHPL) -o $@ $< $(CHFLAGS)

clean:
	rm -f $(TARGETS) basic_c basic_chpl


