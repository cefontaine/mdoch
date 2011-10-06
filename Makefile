all: src c eval

src: FORCE
	cd src && $(MAKE)

c: FORCE
	cd c && $(MAKE)

eval: FORCE
	cd eval && $(MAKE)

FORCE:
