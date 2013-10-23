#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <ruby.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include "allegro_wrap.h"


void check_error(int error)
{
	if (error)
	{
		printf("Fatal error\n");
		abort();
	}
}


int main(int argc, char **argv)
{
	int error;
	
	// Initialize Ruby
	ruby_init();
	ruby_init_loadpath();
	
	rb_require("./lib/bitrpg");
	Init_allegro_wrap();
	
	// Initialize Allegro
	al_init();
	al_init_image_addon();
	al_install_keyboard();
	
	// Launch script
	rb_load_protect(rb_str_new_cstr("./bin/main.rb"), false, &error);
	check_error(error);
	
	// Cleanup
	ruby_finalize();
	return 0;
}
