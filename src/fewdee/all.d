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
// public import fewdee.allegro_manager; // shouldn't be "too public", I guess
public import fewdee.canned_updaters;
public import fewdee.display_manager;
public import fewdee.engine;
public import fewdee.event;
public import fewdee.game_state;
public import fewdee.interpolators;
public import fewdee.low_level_event_handler;
public import fewdee.positionable;
public import fewdee.resource_manager;
public import fewdee.state_manager;
public import fewdee.updater;
public import fewdee.llr.audio_sample;
public import fewdee.llr.audio_stream;
public import fewdee.llr.bitmap;
public import fewdee.llr.font;
public import fewdee.llr.low_level_resource;
public import fewdee.sg.drawable;
public import fewdee.sg.drawing_visitor;
public import fewdee.sg.group;
public import fewdee.sg.guish;
public import fewdee.sg.node;
public import fewdee.sg.node_visitor;
public import fewdee.sg.sprite;
public import fewdee.sg.srt;
public import fewdee.sg.text;
