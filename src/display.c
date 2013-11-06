#include "bitrpg.h"


static
void display_free(void *p)
{
	if (p)
		al_destroy_display(p);
}

VALUE display_new(VALUE cls, VALUE size)
{
	int width = NUM2INT(rb_funcall(size, rb_intern("x"), 0));
	int height = NUM2INT(rb_funcall(size, rb_intern("y"), 0));
	
	// Display configuration
	al_reset_new_display_options();
	al_set_new_display_flags(ALLEGRO_WINDOWED);
	al_set_new_display_option(ALLEGRO_VSYNC, 1, ALLEGRO_SUGGEST);
	
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

VALUE display_activate(VALUE self)
{
	ALLEGRO_DISPLAY *display = RDATA(self)->data;
	al_set_target_backbuffer(display);
	return Qnil;
}

VALUE display_clear(VALUE self)
{
	display_activate(self);
	al_clear_to_color(al_map_rgb(0, 0, 0));
	return Qnil;
}

VALUE display_flip(VALUE self)
{
	display_activate(self);
	al_flip_display();
	return Qnil;
}

VALUE display_size(VALUE self)
{
	ALLEGRO_DISPLAY *display = RDATA(self)->data;
	int width = al_get_display_width(display);
	int height = al_get_display_height(display);
	
	VALUE vector_c = rb_const_get(rb_cObject, rb_intern("Vector"));
	VALUE size = rb_funcall(vector_c, rb_intern("[]"), 2,
		INT2NUM(width), INT2NUM(height));
	return size;
}

void Init_display()
{
	rb_require("./lib/core/display");
	
	// class Display
	
	VALUE display_c = rb_const_get(rb_cObject, rb_intern("Display"));
	rb_define_singleton_method(display_c, "new", display_new, 1);
	
	rb_define_method(display_c, "close", display_close, 0);
	rb_define_method(display_c, "title=", display_title_set, 1);
	rb_define_method(display_c, "activate", display_activate, 0);
	rb_define_method(display_c, "clear", display_clear, 0);
	rb_define_method(display_c, "flip", display_flip, 0);
	rb_define_method(display_c, "size", display_size, 0);
	
	// TODO
	// title
}