module allegro5.allegro;

version(ALLEGRO_NO_PRAGMA_LIB) {}
else
{
	pragma(lib, "allegro");
}

public {
	import allegro5.al_time;
	import allegro5.base;
	import allegro5.system;
	import allegro5.config;
	import allegro5.path;
	import allegro5.al_debug;
	import allegro5.display;
	import allegro5.transformations;
	import allegro5.color;
	import allegro5.bitmap;
	import allegro5.bitmap_io;
	import allegro5.events;
	import allegro5.timer;
	import allegro5.keyboard;
	import allegro5.keycodes;
	import allegro5.mouse;
	import allegro5.joystick;
	import allegro5.memory;
	import allegro5.error;
	import allegro5.file;
	import allegro5.utf8;
	import allegro5.fixed;
	import allegro5.fshook;
	import allegro5.threads;
	import allegro5.tls;
}
