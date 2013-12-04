#include <ruby.h>
#include <SDL/SDL.h>

Uint32
color_to_rgba(VALUE color, const SDL_PixelFormat* format)
{
	Uint8 r = NUM2INT(rb_funcall(color, rb_intern("r"), 0));
	Uint8 g = NUM2INT(rb_funcall(color, rb_intern("g"), 0));
	Uint8 b = NUM2INT(rb_funcall(color, rb_intern("b"), 0));
	Uint8 a = NUM2INT(rb_funcall(color, rb_intern("a"), 0));
	Uint32 rgba = SDL_MapRGBA(format, r, g, b, a);
	return rgba;
}
