/**
 * One import to rule them all.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.all;

public import allegro5.allegro;
public import allegro5.allegro_font;
public import allegro5.allegro_ttf;
public import allegro5.allegro_primitives;

public import fewdee.aabb;
// public import fewdee.allegro_manager; // shouldn't be "too public", I guess
public import fewdee.abstracted_input;
public import fewdee.canned_updaters;
public import fewdee.display_manager;
public import fewdee.engine;
public import fewdee.event;
public import fewdee.event_handler;
public import fewdee.game_state;
public import fewdee.interpolators;
public import fewdee.positionable;
public import fewdee.ref_counted_wrappers; // TODO: remove this
public import fewdee.resource_manager;
public import fewdee.state_manager;
public import fewdee.updater;
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
