CHPL=chpl
FLAGS=--fast
TARGETS=array vector allpairs2d

all: $(TARGETS)

%: %.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


