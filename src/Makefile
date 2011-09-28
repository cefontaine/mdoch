CHPL=chpl
FLAGS=--fast
TARGETS=allpairs2d veldist fmm

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


