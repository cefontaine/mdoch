CHPL=chpl
FLAGS=--fast
TARGETS=dist serial slocale mlocale
REALBINS=$(addsuffix _real, $(TARGETS))

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $< $(FLAGS)

clean:
	rm -f $(TARGETS) $(REALBINS)


