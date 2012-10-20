module allegro5.system;

import allegro5.internal.da5;
import allegro5.config;
import allegro5.path;
import allegro5.base;

version(Tango)
{
	import tango.stdc.stdlib : atexit;
}
else
{
	import std.c.stdlib : atexit;
}

extern (C)
{
	struct ALLEGRO_SYSTEM {};

	bool al_install_system(int vers, int function(void function()) atexit_ptr);
	void al_uninstall_system();
	bool al_is_system_installed();
	ALLEGRO_CONFIG* al_get_system_config();

	bool al_init()
	{
		return al_install_system(ALLEGRO_VERSION_INT, &atexit);
	}

	enum 
	{
		ALLEGRO_RESOURCES_PATH = 0,
		ALLEGRO_TEMP_PATH,
		ALLEGRO_USER_DATA_PATH,
		ALLEGRO_USER_HOME_PATH,
		ALLEGRO_USER_SETTINGS_PATH,
		ALLEGRO_USER_DOCUMENTS_PATH,
		ALLEGRO_EXENAME_PATH,
		ALLEGRO_LAST_PATH // must be last
	}

	ALLEGRO_PATH* get_standard_path(int id);
	void al_set_exe_name(in char* path);

	void al_set_org_name(in char* orgname);
	void al_set_app_name(in char* appname);
	const_char* al_get_org_name();
	const_char* al_get_app_name();

	bool al_inhibit_screensaver(bool inhibit);
}
