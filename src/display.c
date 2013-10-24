#include <ruby.h>
#include <allegro5/allegro.h>
#include "bitrpg.h"


static
void display_free(void *p)
{
	if (p)
		al_destroy_display(p);
}

VALUE display_new(VALUE cls, VALUE size)
{
	int width = NUM2INT(rb_ary_entry(size, 0));
	int height = NUM2INT(rb_ary_entry(size, 1));
	
	al_reset_new_display_options();
	al_set_new_display_flags(ALLEGRO_WINDOWED);
	ALLEGRO_DISPLAY *display = al_create_display(width, height);
	
	if (!display)
		rb_raise(rb_eStandardError, "Could not open display");
	
	VALUE obj = rb_data_object_alloc(cls, display, NULL, display_free);
	return obj;
}

VALUE display_close(VALUE self)
{
	display_free(RDATA(self)->data);
	RDATA(self)->data = NULL;
	return Qnil;
}

VALUE display_title_set(VALUE self, VALUE title)
{
	ALLEGRO_DISPLAY *display = RDATA(self)->data;
	al_set_window_title(display, rb_string_value_cstr(&title));
	return Qnil;
}

/**	Enables the display for further drawing
*/
VALUE display_activate(VALUE self)
{
	// rb_p(self);
	
	ALLEGRO_DISPLAY *display = RDATA(self)->data;
	al_set_target_backbuffer(display);
	return Qnil;
}

/**	Clears the display to black
*/
VALUE display_clear(VALUE self)
{
	// Is directly calling a C defined Ruby method safe?
	display_activate(self);
	al_clear_to_color(al_map_rgb(0, 0, 0));
	return Qnil;
}

/**	Flips the double buffer of the display
*/
VALUE display_flip(VALUE self)
{
	display_activate(self);
	al_flip_display();
	return Qnil;
}

/**	Returns an array with [width, height]
*/
VALUE display_size(VALUE self)
{
	ALLEGRO_DISPLAY *display = RDATA(self)->data;
	int width = al_get_display_width(display);
	int height = al_get_display_height(display);
	
	VALUE size = rb_ary_new3(2, INT2NUM(width), INT2NUM(height));
	return size;
}

void Init_display()
{
	rb_require("./lib/draw_target");
	
	// class Display
	
	VALUE display_c = rb_define_class("Display", rb_cObject);
	VALUE draw_target_m = rb_const_get(rb_cObject, rb_intern("DrawTarget"));
	rb_include_module(display_c, draw_target_m);
	rb_define_singleton_method(display_c, "new", display_new, 1);
	
	rb_define_method(display_c, "close", display_close, 0);
	rb_define_method(display_c, "title=", display_title_set, 1);
	rb_define_method(display_c, "activate", display_activate, 0);
	rb_define_method(display_c, "clear", display_clear, 0);
	rb_define_method(display_c, "flip", display_flip, 0);
	rb_define_method(display_c, "size", display_size, 0);
	rb_attr(display_c, rb_intern("events"), true, false, false);
	
	// TODO
	// title
}