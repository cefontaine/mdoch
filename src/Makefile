CHPL=chpl
FLAGS=--fast
TARGETS=allpairs2d veldist cellsub nebrlist cellspc nebrlistpc trajsep \
	thermosoft thermolj rdfsoft sfmm fmm
REALBINS=$(addsuffix _real, $(TARGETS))

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS) $(REALBINS)


