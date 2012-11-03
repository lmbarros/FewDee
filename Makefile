#
# Not exactly an award-wining build system, but should work for now
#

DMDCOMMONFLAGS=-Isrc
DMDFLAGS=-unittest $(DMDCOMMONFLAGS)
# DMDFLAGS=-O -inline $(DMDCOMMONFLAGS)
# DMDFLAGS=-debug $(DMDCOMMONFLAGS)

DMDLINKFLAGS=twodee.a -L-lallegro -L-lallegro_image -L-lallegro_font -L-lallegro_ttf

all: twodee.a twodeedemo

# The library
twodee.a: src/twodee/*
	dmd $(DMDFLAGS) -lib -oftwodee.a src/allegro5/*.d src/allegro5/internal/*.d src/twodee/*.d

twodeedemo: examples/twodeedemo.d twodee.a
	dmd $(DMDFLAGS) $(DMDLINKFLAGS) -oftwodeedemo examples/twodeedemo.d twodee.a

clean:
	rm -f twodee.a twodeedemo.*

