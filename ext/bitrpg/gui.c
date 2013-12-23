#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include "bitrpg.h"


VALUE cFont;

static void
font_free(void *p)
{
	if (p)
	{
		TTF_CloseFont(p);
	}
}

VALUE
font_new(VALUE self, VALUE filename, VALUE size)
{
	const char *filename_str = StringValueCStr(filename);
	int ptsize = NUM2INT(size);
	
	TTF_Font *font = TTF_OpenFont(filename_str, ptsize);
	
	if (!font)
		rb_raise(rb_eRuntimeError, "Could not load font '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(self, font, NULL, font_free);
	return obj;
}

VALUE
font_render(VALUE self, VALUE text, VALUE color, VALUE wrap)
{
	TTF_Font *font = RDATA(self)->data;
	const char *text_str = StringValueCStr(text);
	SDL_Color fg = to_color(color);
	SDL_Surface *surface;
	
	if (wrap == Qnil)
	{
		surface = TTF_RenderText_Blended(font, text_str, fg);
	}
	else
	{
		int wrap_length = NUM2INT(wrap);
		surface = TTF_RenderText_Blended_Wrapped(font, text_str, fg, wrap_length);
	}
	
	VALUE obj = rb_data_object_alloc(cSurface, surface, NULL, surface_free);
	return obj;
}

void Init_bitrpg_gui()
{
	cFont = rb_define_class("Font", rb_cObject);
	rb_define_singleton_method(cFont, "new", font_new, 2);
	rb_define_method(cFont, "render", font_render, 3);
}