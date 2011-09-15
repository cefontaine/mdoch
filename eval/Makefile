CHPL=chpl
FLAGS=--fast
TARGETS=array

all: $(TARGETS)

%: %.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


