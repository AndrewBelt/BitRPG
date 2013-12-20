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
	SDL_Surface *source_surface = RDATA(self)->data;
	SDL_Surface *dest_surface;
	SDL_Rect source_rect;
	SDL_Rect dest_rect;
	int zoom;
	
	// dest_surface
	if (argc >= 1 && argv[0] != Qnil) 
	{
		dest_surface = RDATA(argv[0])->data;
	}
	else
	{
		rb_raise(rb_eRuntimeError, "Destination surface required");
	}
	
	// source_rect
	if (argc >= 2 && argv[1] != Qnil)
	{
		source_rect = to_rect(argv[1]);
	}
	else
	{
		source_rect.x = 0;
		source_rect.y = 0;
		source_rect.w = source_surface->w;
		source_rect.h = source_surface->h;
	}
	
	// dest_position
	if (argc >= 3 && argv[2] != Qnil)
	{
		SDL_Point dest_position = to_point(argv[2]);
		dest_rect.x = dest_position.x;
		dest_rect.y = dest_position.y;
	}
	else
	{
		dest_rect.x = 0;
		dest_rect.y = 0;
	}
	
	// zoom
	if (argc >= 4)
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
surface_fill(VALUE self, VALUE fill_rect, VALUE color)
{
	SDL_Surface *surface = RDATA(self)->data;
	Uint32 pixel = to_pixel(color, surface->format);
	
	if (fill_rect != Qnil)
	{
		SDL_Rect rect = to_rect(fill_rect);
		SDL_FillRect(surface, &rect, pixel);
	}
	else
	{
		SDL_FillRect(surface, NULL, pixel);
	}
	
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
	rb_define_method(cSurface, "fill", surface_fill, 2);
	rb_define_method(cSurface, "size", surface_size, 0);
}