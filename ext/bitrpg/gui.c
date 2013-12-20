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
font_render(VALUE self, VALUE text, VALUE color)
{
	TTF_Font *font = RDATA(self)->data;
	const char *text_str = StringValueCStr(text);
	SDL_Color fg = color_to_pixel(color);
	
	SDL_Surface *surface = TTF_RenderText_Solid(font, text_str, fg);
	
	VALUE obj = rb_data_object_alloc(cSurface, surface, NULL, surface_free);
	return obj;
}

void Init_bitrpg_gui()
{
	cFont = rb_define_class("Font", rb_cObject);
	rb_define_singleton_method(cFont, "new", font_new, 2);
	rb_define_method(cFont, "render", font_render, 2);
}