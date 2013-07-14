/**
 * One import to rule them all.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.all;

// Not sure if the Allegro interface should be publicly imported by this
// file. Anyway, here they are...
public import allegro5.allegro;
public import allegro5.allegro_audio;
public import allegro5.allegro_color;
public import allegro5.allegro_font;
public import allegro5.allegro_native_dialog;
public import allegro5.allegro_primitives;

// The FewDee public interface is imported here
public import fewdee.aabb;
public import fewdee.abstracted_input;
public import fewdee.allegro_manager;
public import fewdee.audio_manager;
public import fewdee.audio_sample;
public import fewdee.audio_stream;
public import fewdee.bitmap;
public import fewdee.canned_updaters;
public import fewdee.color;
public import fewdee.display_manager;
public import fewdee.engine;
public import fewdee.event;
public import fewdee.event_manager;
public import fewdee.font;
public import fewdee.game_loop;
public import fewdee.game_state;
public import fewdee.interpolators;
public import fewdee.low_level_event_handler;
public import fewdee.low_level_resource;
public import fewdee.resource_manager;
public import fewdee.sprite;
public import fewdee.state_manager;
public import fewdee.updater;
public import fewdee.sg.drawable;
public import fewdee.sg.drawing_visitor;
public import fewdee.sg.group;
public import fewdee.sg.node;
public import fewdee.sg.node_events;
public import fewdee.sg.node_visitor;
public import fewdee.sg.sprite;
public import fewdee.sg.srt;
public import fewdee.sg.text;
