all: src c eval

src: FORCE
	cd $@ && $(MAKE)

c: FORCE
	cd $@ && $(MAKE)

eval: FORCE
	cd $@ && $(MAKE)

report: FORCE
	cd $@ && $(MAKE)

FORCE:
