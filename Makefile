
.PHONY: twodeedemo

all: twodeedemo

twodeedemo:
	dmd -oftwodeedemo src/*.d src/allegro5/*.d src/allegro5/internal/*.d src/twodee/*.d