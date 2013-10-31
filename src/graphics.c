#include "bitrpg.h"


static VALUE bitmap_c;
static ID ref_id;


static void
bitmap_free(void *p)
{
	if (p)
		al_destroy_bitmap(p);
}

VALUE
bitmap_new(VALUE cls, VALUE size)
{
	int width = NUM2INT(rb_ary_entry(size, 0));
	int height = NUM2INT(rb_ary_entry(size, 1));
	
	ALLEGRO_BITMAP *bitmap = al_create_bitmap(width, height);
	
	if (!bitmap)
		rb_raise(rb_eStandardError, "Could not create bitmap");
	
	VALUE obj = rb_data_object_alloc(cls, bitmap, NULL, bitmap_free);
	return obj;
}

VALUE
bitmap_load(VALUE cls, VALUE filename)
{
	char *filename_str = rb_string_value_cstr(&filename);
	ALLEGRO_BITMAP *bitmap = al_load_bitmap(filename_str);
	
	if (!bitmap)
		rb_raise(rb_eIOError, "Could not load bitmap '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(cls, bitmap, NULL, bitmap_free);
	return obj;
}

VALUE
bitmap_activate(VALUE self)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	al_set_target_bitmap(bitmap);
	return Qnil;
}

VALUE
bitmap_clear(VALUE self)
{
	bitmap_activate(self);
	al_clear_to_color(al_map_rgb(0, 0, 0));
	return Qnil;
}

VALUE
bitmap_size(VALUE self)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int width = al_get_bitmap_width(bitmap);
	int height = al_get_bitmap_height(bitmap);
	
	VALUE vector_c = rb_const_get(rb_cObject, rb_intern("Vector"));
	VALUE size = rb_funcall(vector_c, rb_intern("[]"), 2,
		INT2NUM(width), INT2NUM(height));
	return size;
}

VALUE
bitmap_blit(int argc, VALUE *argv, VALUE self)
{
	// TODO
	// Put in default values instead of silently failing
	if (argc < 7)
		return Qnil;
	
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int sx = NUM2INT(argv[0]);
	int sy = NUM2INT(argv[1]);
	int sw = NUM2INT(argv[2]);
	int sh = NUM2INT(argv[3]);
	int x = NUM2INT(argv[4]);
	int y = NUM2INT(argv[5]);
	int zoom = NUM2INT(argv[6]);
	
	int w = sw * zoom;
	int h = sh * zoom;
	al_draw_scaled_bitmap(bitmap, sx, sy, sw, sh, x, y, w, h, 0);
	
	return Qnil;
}

VALUE
bitmap_clip(VALUE self, VALUE position, VALUE size)
{
	ALLEGRO_BITMAP *bitmap = RDATA(self)->data;
	int x = NUM2INT(rb_ary_entry(position, 0));
	int y = NUM2INT(rb_ary_entry(position, 1));
	int w = NUM2INT(rb_ary_entry(size, 0));
	int h = NUM2INT(rb_ary_entry(size, 1));
	
	ALLEGRO_BITMAP *bitmap_sub = al_create_sub_bitmap(bitmap, x, y, w, h);
	ALLEGRO_BITMAP *bitmap_clipped = al_clone_bitmap(bitmap_sub);
	al_destroy_bitmap(bitmap_sub);
	
	if (!bitmap_clipped)
		rb_raise(rb_eStandardError, "Could not create clipped bitmap");
	
	VALUE obj = rb_data_object_alloc(bitmap_c, bitmap_clipped, NULL, bitmap_free);
	return obj;
}

ALLEGRO_COLOR
color_map(VALUE color)
{
	float r = NUM2DBL(rb_iv_get(color, "@r"));
	float g = NUM2DBL(rb_iv_get(color, "@g"));
	float b = NUM2DBL(rb_iv_get(color, "@b"));
	float a = NUM2DBL(rb_iv_get(color, "@a"));
	
	return al_map_rgba_f(r, g, b, a);
}

void
Init_graphics()
{
	rb_require("./lib/core/graphics");
	
	// class Bitmap
	
	bitmap_c = rb_const_get(rb_cObject, rb_intern("Bitmap"));
	rb_define_singleton_method(bitmap_c, "new", bitmap_new, 1);
	rb_define_singleton_method(bitmap_c, "load", bitmap_load, 1);
	
	rb_define_method(bitmap_c, "activate", bitmap_activate, 0);
	rb_define_method(bitmap_c, "clear", bitmap_clear, 0);
	rb_define_method(bitmap_c, "size", bitmap_size, 0);
	rb_define_method(bitmap_c, "blit", bitmap_blit, -1);
	rb_define_method(bitmap_c, "clip", bitmap_clip, 2);
	
	// Globals
	ref_id = rb_intern("[]");
}