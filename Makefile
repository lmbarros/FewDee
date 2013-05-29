#
# Not exactly an award-wining build system, but should work for now
#

DMDCOMMONFLAGS=-Isrc -w -wi
DMDFLAGS=-unittest $(DMDCOMMONFLAGS)
# DMDFLAGS=-O -inline $(DMDCOMMONFLAGS)
# DMDFLAGS=-debug -gc $(DMDCOMMONFLAGS)

DMDLINKFLAGS=fewdee.a -L-lallegro -L-lallegro_image -L-lallegro_font \
   -L-lallegro_ttf -L-lallegro_primitives -L-lallegro_dialog -L-lallegro_audio -L-lallegro_acodec

FEWDEE_SOURCES=src/allegro5/*.d src/allegro5/internal/*.d \
   src/fewdee/*.d src/fewdee/internal/*.d src/fewdee/llr/*.d src/fewdee/sg/*.d

# Implicit rule to build an example
%.example: examples/%.d
	dmd $(DMDFLAGS) $(DMDLINKFLAGS) -of$@ $< fewdee.a


# All
all: fewdee.a fewdeedemo.example #states_simple.example updater_simple.example \
#     updater_canned.example sg_solar_system.example \
#     sg_parallax_scrolling.example interpolators_graphs.example \
#     abstracted_input_simple.example


# The library
fewdee.a: src/fewdee/*
	dmd $(DMDFLAGS) -lib -offewdee.a $(FEWDEE_SOURCES)


# The examples
fewdeedemo.example: examples/fewdeedemo.d fewdee.a
states_simple.example: examples/states_simple.d fewdee.a
updater_simple.example: examples/updater_simple.d fewdee.a
updater_canned.example: examples/updater_canned.d fewdee.a
sg_solar_system.example: examples/sg_solar_system.d fewdee.a
sg_parallax_scrolling.example: examples/sg_parallax_scrolling.d fewdee.a
interpolators_graphs.example: examples/interpolators_graphs.d fewdee.a
abstracted_input_simple.example: examples/abstracted_input_simple.d fewdee.a


# Unit tests
fewdee_unit_tests: $(FEWDEE_SOURCES) src/fewdee_unit_tests.d
	dmd $(DMDFLAGS) src/fewdee_unit_tests.d $(FEWDEE_SOURCES)

test: fewdee_unit_tests
	./fewdee_unit_tests


# Clean
clean:
	rm -f fewdee.a *.o *.example fewdee_unit_tests
