#
# Not exactly an award-wining build system, but should work for now
#

DMDCOMMONFLAGS=-Isrc
DMDFLAGS=-unittest $(DMDCOMMONFLAGS)
# DMDFLAGS=-O -inline $(DMDCOMMONFLAGS)
# DMDFLAGS=-debug -gc $(DMDCOMMONFLAGS)

DMDLINKFLAGS=twodee.a -L-lallegro -L-lallegro_image -L-lallegro_font -L-lallegro_ttf

# Implicit rule to build an example
%.example: examples/%.d
	dmd $(DMDFLAGS) $(DMDLINKFLAGS) -of$@ $< twodee.a


# All
all: twodee.a twodeedemo.example states_simple.example


# The library
twodee.a: src/twodee/*
	dmd $(DMDFLAGS) -lib -oftwodee.a src/allegro5/*.d src/allegro5/internal/*.d \
	   src/twodee/*.d src/twodee/sg/*.d


# The examples
twodeedemo.example: examples/twodeedemo.d
states_simple.example: examples/states_simple.d


# Clean
clean:
	rm -f twodee.a *.o *.example
