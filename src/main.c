#include <stdlib.h>
#include <stdio.h>
#include <ruby.h>
#include "bitrpg.h"


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

int
main(int argc, char **argv)
{
	int error;
	
	init_allegro();
	
	// Initialize Ruby
	ruby_init();
	ruby_init_loadpath();
	// $: << './lib'
	rb_funcall(rb_gv_get("$:"), rb_intern("<<"), 1, rb_str_new2("./lib"));
	
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