all: src c

src: FORCE
	cd src && $(MAKE)

c: FORCE
	cd c && $(MAKE)

FORCE:
