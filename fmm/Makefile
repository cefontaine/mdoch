CHPL=chpl
FLAGS=--fast
TARGETS=serial slocale
REALBINS=$(addsuffix _real, $(TARGETS))

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS) $(REALBINS)


