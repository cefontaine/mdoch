CHPL=chpl

TARGETS=allpairs2d

all: $(TARGETS)

%: %.chpl
	$(CHPL) -o $@ $<

clean:
	rm -f $(TARGETS)


