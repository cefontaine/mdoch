CHPL=chpl
FLAGS=--fast
TARGETS=array vector

all: $(TARGETS)

%: %.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS)


