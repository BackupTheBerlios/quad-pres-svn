all: quad-pres-path.png

quad-pres-path.png: quad-pres-path.svg
	rsvg $< $@

quad-pres-path.svg: gen-path.pl
	perl $< > $@

