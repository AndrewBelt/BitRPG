#include <stdlib.h>
#include <stdio.h>
#include <ruby.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include "bitrpg.h"


void
check_error(int error)
{
	if (error)
	{
		printf("Fatal error\n");
		abort();
	}
}

static VALUE
bitrpg_run(VALUE filename)
{
	Init_bitrpg();
	rb_funcall(rb_cObject, rb_intern("load"), 1, filename);
	return Qnil;
}

static void
print_exception(VALUE exc)
{
	rb_p(exc);
	VALUE backtrace = rb_funcall(exc, rb_intern("backtrace"), 0);
	rb_funcall(rb_cObject, rb_intern("puts"), 1, backtrace);
}

void
init_allegro()
{
	check_error(!al_init());
	check_error(!al_init_image_addon());
	check_error(!al_install_keyboard());
	al_init_font_addon();
	al_init_ttf_addon();
}

int
main(int argc, char **argv)
{
	int error;
	init_allegro();
	
	// Initialize Ruby
	ruby_init();
	ruby_init_loadpath();
	
	// Run the game
	rb_protect(bitrpg_run, rb_str_new2("./lib/main.rb"), &error);
	
	if (error)
	{
		print_exception(rb_errinfo());
		rb_set_errinfo(Qnil);
	}
	
	// Cleanup
	ruby_finalize();
	return 0;
}