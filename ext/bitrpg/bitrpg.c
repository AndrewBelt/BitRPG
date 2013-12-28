#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include "bitrpg.h"


SDL_Point
from_vector(VALUE vector)
{
	SDL_Point point;
	point.x = NUM2INT(rb_funcall(vector, rb_intern("x"), 0));
	point.y = NUM2INT(rb_funcall(vector, rb_intern("y"), 0));
	return point;
}

VALUE
to_vector(SDL_Point point)
{
	VALUE cVector = rb_const_get(rb_cObject, rb_intern("Vector"));
	return rb_funcall(cVector, rb_intern("new"), 2,
		INT2NUM(point.x), INT2NUM(point.y));
}

SDL_Rect
from_rect(VALUE rect)
{
	SDL_Point position = from_vector(rb_funcall(rect, rb_intern("position"), 0));
	SDL_Point size = from_vector(rb_funcall(rect, rb_intern("size"), 0));
	
	SDL_Rect rect2;
	rect2.x = position.x;
	rect2.y = position.y;
	rect2.w = size.x;
	rect2.h = size.y;
	return rect2;
}

SDL_Color
to_color(VALUE color)
{
	SDL_Color color2;
	color2.r = NUM2INT(rb_funcall(color, rb_intern("r"), 0));
	color2.g = NUM2INT(rb_funcall(color, rb_intern("g"), 0));
	color2.b = NUM2INT(rb_funcall(color, rb_intern("b"), 0));
	color2.a = NUM2INT(rb_funcall(color, rb_intern("a"), 0));
	return color2;
}

Uint32
to_pixel(VALUE color, const SDL_PixelFormat* format)
{
	SDL_Color color2 = to_color(color);
	Uint32 pixel = SDL_MapRGBA(format, color2.r, color2.g, color2.b, color2.a);
	return pixel;
}

void
Init_bitrpg_native()
{
	// Initialize bitrpg modules
	Init_bitrpg_graphics();
	Init_bitrpg_event();
	Init_bitrpg_gui();
	
	// Initialize SDL
	SDL_Init(SDL_INIT_VIDEO);
	IMG_Init(IMG_INIT_PNG);
	TTF_Init();
}