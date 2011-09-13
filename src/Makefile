CHPL=chpl

TARGETS=allpairs2d

all: $(TARGETS)

%: %.chpl common.chpl
	$(CHPL) -o $@ $<

clean:
	rm -f $(TARGETS)


