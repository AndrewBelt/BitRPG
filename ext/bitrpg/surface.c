#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include "bitrpg.h"


VALUE cSurface;

void
surface_free(void *p)
{
	if (p)
	{
		SDL_FreeSurface(p);
	}
}

VALUE
surface_new(VALUE self, VALUE size)
{
	int w = NUM2INT(rb_funcall(size, rb_intern("x"), 0));
	int h = NUM2INT(rb_funcall(size, rb_intern("y"), 0));
	
	SDL_Surface *surface = SDL_CreateRGBSurface(0, w, h, 32, 0, 0, 0, 0);
	
	if (!surface)
		rb_raise(rb_eRuntimeError, "Could not create surface");
	
	VALUE obj = rb_data_object_alloc(self, surface, NULL, surface_free);
	return obj;
}

VALUE
surface_load(VALUE self, VALUE filename)
{
	const char *filename_str = StringValueCStr(filename);
	SDL_Surface *surface = IMG_Load(filename_str);
	
	if (!surface)
		rb_raise(rb_eRuntimeError, "Could not load image '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(self, surface, NULL, surface_free);
	return obj;
}

VALUE
surface_blit(int argc, VALUE *argv, VALUE self)
{
	SDL_Surface *dest_surface = RDATA(self)->data;
	SDL_Surface *source_surface;
	SDL_Rect dest_rect;
	SDL_Rect source_rect;
	int zoom;
	
	ID sym_x = rb_intern("x");
	ID sym_y = rb_intern("y");
	
	if (argc >= 1) // source_surface
	{
		source_surface = RDATA(argv[0])->data;
	}
	else
	{
		rb_raise(rb_eRuntimeError, "Source surface required");
	}
	
	if (argc >= 2 && argv[1] != Qnil) // source_rect
	{
		VALUE source_position = rb_funcall(argv[1], rb_intern("position"), 0);
		VALUE source_size = rb_funcall(argv[1], rb_intern("size"), 0);
		source_rect.x = NUM2INT(rb_funcall(source_position, sym_x, 0));
		source_rect.y = NUM2INT(rb_funcall(source_position, sym_y, 0));
		source_rect.w = NUM2INT(rb_funcall(source_size, sym_x, 0));
		source_rect.h = NUM2INT(rb_funcall(source_size, sym_y, 0));
	}
	else
	{
		source_rect.x = 0;
		source_rect.y = 0;
		source_rect.w = source_surface->w;
		source_rect.h = source_surface->h;
	}
	
	if (argc >= 3) // dest_position
	{
		dest_rect.x = NUM2INT(rb_funcall(argv[2], sym_x, 0));
		dest_rect.y = NUM2INT(rb_funcall(argv[2], sym_y, 0));
	}
	else
	{
		dest_rect.x = 0;
		dest_rect.y = 0;
	}
	
	if (argc >= 4) // zoom
	{
		zoom = NUM2INT(argv[3]);
		
		if (zoom < 1)
			rb_raise(rb_eRuntimeError, "Zoom must be at least 1");
	}
	else
	{
		zoom = 1;
	}
	
	dest_rect.w = source_rect.w * zoom;
	dest_rect.h = source_rect.h * zoom;
	
	if (zoom == 1)
	{
		SDL_BlitSurface(source_surface, &source_rect, dest_surface, &dest_rect);
	}
	else
	{
		SDL_BlitScaled(source_surface, &source_rect, dest_surface, &dest_rect);
	}
	
	return Qnil;
}

VALUE
surface_fill(VALUE self, VALUE color)
{
	SDL_Surface *surface = RDATA(self)->data;
	Uint32 rgba = color_to_rgba(color, surface->format);
	SDL_FillRect(surface, NULL, rgba);
	return Qnil;
}

VALUE
surface_size(VALUE self)
{
	SDL_Surface *surface = RDATA(self)->data;
	int w = surface->w;
	int h = surface->h;
	
	VALUE cVector = rb_const_get(rb_cObject, rb_intern("Vector"));
	VALUE size = rb_funcall(cVector, rb_intern("[]"), 2,
		INT2NUM(w), INT2NUM(h));
	return size;
}

void
Init_bitrpg_surface()
{
	cSurface = rb_define_class("Surface", rb_cObject);
	rb_define_singleton_method(cSurface, "new", surface_new, 1);
	rb_define_singleton_method(cSurface, "load", surface_load, 1);
	rb_define_method(cSurface, "blit", surface_blit, -1);
	rb_define_method(cSurface, "fill", surface_fill, 1);
	rb_define_method(cSurface, "size", surface_size, 0);
}