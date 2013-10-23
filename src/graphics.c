#include "allegro_wrap.h"
#include <stdbool.h>
#include <ruby.h>
#include <allegro5/allegro.h>


static VALUE bitmap_c;


static
void bitmap_free(void *p)
{
	if (p)
		al_destroy_bitmap(p);
}


VALUE bitmap_new(VALUE cls, VALUE size)
{
	int width = NUM2INT(rb_ary_entry(size, 0));
	int height = NUM2INT(rb_ary_entry(size, 1));
	
	ALLEGRO_BITMAP *bitmap = al_create_bitmap(width, height);
	
	if (!bitmap)
		rb_raise(rb_eStandardError, "Could not create bitmap");
	
	VALUE obj = rb_data_object_alloc(cls, bitmap, NULL, bitmap_free);
	return obj;
}


VALUE bitmap_load(VALUE cls, VALUE filename)
{
	char *filename_str = rb_string_value_cstr(&filename);
	ALLEGRO_BITMAP *bitmap = al_load_bitmap(filename_str);
	
	if (!bitmap)
		rb_raise(rb_eIOError, "Could not open bitmap");
	
	VALUE obj = rb_data_object_alloc(cls, bitmap, NULL, bitmap_free);
	return obj;
}


/**	Enables the bitmap for further drawing
*/
VALUE bitmap_activate(VALUE self)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	al_set_target_bitmap(bitmap);
	return Qnil;
}


/**	Clears the bitmap to black
*/
VALUE bitmap_clear(VALUE self)
{
	bitmap_activate(self);
	al_clear_to_color(al_map_rgb(0, 0, 0));
	return Qnil;
}


/**	Returns an array with [width, height]
*/
VALUE bitmap_size(VALUE self)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int width = al_get_bitmap_width(bitmap);
	int height = al_get_bitmap_height(bitmap);
	
	VALUE size = rb_ary_new3(2, INT2NUM(width), INT2NUM(height));
	return size;
}


VALUE bitmap_blit(VALUE self, VALUE position, VALUE zoom)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int dx = NUM2INT(rb_ary_entry(position, 0));
	int dy = NUM2INT(rb_ary_entry(position, 1));
	int z = NUM2INT(zoom);
	
	if (z <= 1)
	{
		al_draw_bitmap(bitmap, dx, dy, 0);
	}
	else
	{
		int sw = al_get_bitmap_width(bitmap);
		int sh = al_get_bitmap_height(bitmap);
		al_draw_scaled_bitmap(bitmap, 0, 0, sw, sh,
			dx, dy, z * sw, z * sh, 0);
	}
	
	return Qnil;
}


VALUE bitmap_sub(VALUE self, VALUE position, VALUE size)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int x = NUM2INT(rb_ary_entry(position, 0));
	int y = NUM2INT(rb_ary_entry(position, 1));
	int w = NUM2INT(rb_ary_entry(size, 0));
	int h = NUM2INT(rb_ary_entry(position, 1));
	
	ALLEGRO_BITMAP *bitmap_sub = al_create_sub_bitmap(bitmap, x, y, w, h);
	
	if (!bitmap_sub)
		rb_raise(rb_eStandardError, "Could not create sub bitmap");
	
	VALUE obj = rb_data_object_alloc(bitmap_c, bitmap_sub, NULL, bitmap_free);
	rb_iv_set(obj, "@parent", self);
	return obj;
}


void Init_graphics()
{
	// class Bitmap
	
	bitmap_c = rb_define_class("Bitmap", rb_cObject);
	VALUE draw_target_m = rb_const_get(rb_cObject, rb_intern("DrawTarget"));
	rb_include_module(bitmap_c, draw_target_m);
	rb_define_singleton_method(bitmap_c, "new", bitmap_new, 1);
	rb_define_singleton_method(bitmap_c, "load", bitmap_load, 1);
	
	rb_define_method(bitmap_c, "activate", bitmap_activate, 0);
	rb_define_method(bitmap_c, "clear", bitmap_clear, 0);
	rb_define_method(bitmap_c, "size", bitmap_size, 0);
	rb_define_method(bitmap_c, "blit", bitmap_blit, 2);
	rb_define_method(bitmap_c, "sub", bitmap_sub, 2);
	rb_attr(bitmap_c, rb_intern("parent"), true, false, false);
	
	// TODO
	// draw
}