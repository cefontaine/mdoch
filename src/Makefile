CHPL=chpl
FLAGS=--fast
TARGETS=allpairs2d veldist cellsub nebrlist cellspc nebrlistpc fmm

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


