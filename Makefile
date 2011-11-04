all: src c eval report

src: FORCE
	cd $@ && $(MAKE)

c: FORCE
	cd $@ && $(MAKE)

eval: FORCE
	cd $@ && $(MAKE)

report: FORCE
	cd $@ && $(MAKE)

FORCE:
