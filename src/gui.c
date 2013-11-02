#include "bitrpg.h"
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>


void
free_font(void *p)
{
	if (p)
		al_destroy_font(p);
}

VALUE
font_load(VALUE cls, VALUE filename, VALUE size)
{
	char *filename_str = rb_string_value_cstr(&filename);
	int s = NUM2INT(size);
	
	ALLEGRO_FONT *font = al_load_ttf_font(filename_str, s, 0);
	
	if (!font)
		rb_raise(rb_eIOError, "Could not load font '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(cls, font, NULL, free_font);
	return obj;
}

VALUE
font_blit(VALUE self, VALUE color, VALUE x, VALUE y, VALUE text)
{
	ALLEGRO_FONT *font = RDATA(self)->data;
	char *text_str = rb_string_value_cstr(&text);
	ALLEGRO_COLOR alleg_color = value_to_color(color);
	float dx = NUM2DBL(x);
	float dy = NUM2DBL(y);
	
	al_draw_text(font, alleg_color, dx, dy, ALLEGRO_ALIGN_LEFT, text_str);
	return Qnil;
}

void
Init_gui()
{
	rb_require("./lib/core/gui");
	
	VALUE font_c = rb_const_get(rb_cObject, rb_intern("Font"));
	rb_define_singleton_method(font_c, "load", font_load, 2);
	
	rb_define_method(font_c, "blit", font_blit, 4);
}