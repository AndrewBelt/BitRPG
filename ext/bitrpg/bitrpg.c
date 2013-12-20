#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include "bitrpg.h"


SDL_Color
color_to_pixel(VALUE color)
{
	SDL_Color pixel;
	pixel.r = NUM2INT(rb_funcall(color, rb_intern("r"), 0));
	pixel.g = NUM2INT(rb_funcall(color, rb_intern("g"), 0));
	pixel.b = NUM2INT(rb_funcall(color, rb_intern("b"), 0));
	pixel.a = NUM2INT(rb_funcall(color, rb_intern("a"), 0));
	return pixel;
}

Uint32
color_to_rgba(VALUE color, const SDL_PixelFormat* format)
{
	SDL_Color pixel = color_to_pixel(color);
	Uint32 rgba = SDL_MapRGBA(format, pixel.r, pixel.g, pixel.b, pixel.a);
	return rgba;
}

void
Init_bitrpg_native()
{
	Init_bitrpg_window();
	Init_bitrpg_surface();
	Init_bitrpg_event();
	Init_bitrpg_gui();
	
	// Initialize SDL
	SDL_Init(SDL_INIT_VIDEO);
	IMG_Init(IMG_INIT_PNG);
	TTF_Init();
}