DOT=dot
TEX=pdflatex
BIBTEX=bibtex
DVI2PS=dvips
DVI2PDF=dvipdf
PS2PDF=ps2pdf

PROJ=mdoch
SECTIONS=$(wildcard sections/*.tex)
TABLES=$(wildcard tables/*.tex)
FIGURES=$(wildcard figures/*.tex figures/*.pdf)
MISCS=acronyms.tex
BIB=$(PROJ).bib

all: pdf

# force to compile in case of bibtex updated
.PHONY: re
re:
	$(TEX) $(PROJ)
	$(BIBTEX) $(PROJ)
	$(TEX) $(PROJ)

.PHONY: ps
ps: $(PROJ).ps
$(PROJ).ps: $(PROJ).dvi
	$(DVI2PS) $?

.PHONY: pdf
pdf: $(PROJ).pdf
$(PROJ).pdf: $(PROJ).tex $(SECTIONS) $(TABLES) $(FIGURES) $(BIB) $(MISCS)
	$(TEX) $(PROJ).tex
	$(BIBTEX) $(PROJ)
	$(TEX) $(PROJ).tex

.PHONY: pspdf
pspdf: $(PROJ).ps
	$(PS2PDF) $?

clean:
	-rm -f *.log *.aux *.bbl *.blg
	-rm -f *.dvi *.ps *.pdf
