#
# Not exactly an award-wining build system, but should work for now
#

DMDCOMMONFLAGS=-Isrc -w -wi
# DMDFLAGS=-unittest $(DMDCOMMONFLAGS)
# DMDFLAGS=-O -inline $(DMDCOMMONFLAGS)
DMDFLAGS=-debug -gc -unittest $(DMDCOMMONFLAGS)

DMDLINKFLAGS=fewdee.a -L-lallegro -L-lallegro_image -L-lallegro_font \
   -L-lallegro_ttf -L-lallegro_primitives -L-lallegro_dialog \
   -L-lallegro_audio -L-lallegro_acodec

FEWDEE_SOURCES=src/allegro5/*.d src/allegro5/internal/*.d \
   src/fewdee/*.d src/fewdee/internal/*.d src/fewdee/sg/*.d

# Implicit rule to build an example
%.example: examples/%.d
	dmd $(DMDFLAGS) $(DMDLINKFLAGS) -of$@ $< fewdee.a


# All
all: fewdee.a fewdeedemo.example display_manager_info.example \
     states_simple.example interpolators_graphs.example \
     updater_simple.example updater_canned.example \
     updater_canned_audio.example sg_solar_system.example \
     sg_parallax_scrolling.example abstracted_input_simple.example \
     audio_sample_simple.example audio_stream_simple.example \
     sprite_simple.example sprite_animation_events.example \
     game_loop_simple.example game_loop_prediction.example


# The library
fewdee.a: src/fewdee/*
	dmd $(DMDFLAGS) -lib -offewdee.a $(FEWDEE_SOURCES)


# The examples
fewdeedemo.example: examples/fewdeedemo.d fewdee.a
display_manager_info.example: examples/display_manager_info.d fewdee.a
states_simple.example: examples/states_simple.d fewdee.a
updater_simple.example: examples/updater_simple.d fewdee.a
updater_canned.example: examples/updater_canned.d fewdee.a
updater_canned_audio.example: examples/updater_canned_audio.d fewdee.a
sg_solar_system.example: examples/sg_solar_system.d fewdee.a
sg_parallax_scrolling.example: examples/sg_parallax_scrolling.d fewdee.a
interpolators_graphs.example: examples/interpolators_graphs.d fewdee.a
abstracted_input_simple.example: examples/abstracted_input_simple.d fewdee.a
audio_sample_simple.example: examples/audio_sample_simple.d fewdee.a
audio_stream_simple.example: examples/audio_stream_simple.d fewdee.a
sprite_simple.example: examples/sprite_simple.d fewdee.a
sprite_animation_events.example: examples/sprite_animation_events.d fewdee.a
game_loop_simple.example: examples/game_loop_simple.d fewdee.a
game_loop_prediction.example: examples/game_loop_prediction.d fewdee.a


# Unit tests
fewdee_unit_tests: $(FEWDEE_SOURCES) src/fewdee_unit_tests.d
	dmd $(DMDFLAGS) src/fewdee_unit_tests.d $(FEWDEE_SOURCES)

test: fewdee_unit_tests
	./fewdee_unit_tests


# Clean
clean:
	rm -f fewdee.a *.o *.example fewdee_unit_tests
