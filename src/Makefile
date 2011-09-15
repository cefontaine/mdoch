CHPL=chpl
FLAGS=--fast
TARGETS=allpairs2d veldist

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


