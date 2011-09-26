CC=gcc
CHPL=chpl
CFLAGS=-O -lm
CHFLAGS=--fast
TARGETS=array allpairs2d

.PHONY: basic_cmp
all: $(TARGETS) basic_cmp

%: %.chpl
	$(CHPL) -o $@ $< $(CHFLAGS)

basic_cmp: basic_cmp.c basic_cmp.chpl
	$(CC) -o basic_c basic_cmp.c $(CFLAGS)
	$(CHPL) -o basic_chpl basic_cmp.chpl $(CHFLAGS)

clean:
	rm -f $(CTARGETS)
	rm -f $(CHTARGETS)


