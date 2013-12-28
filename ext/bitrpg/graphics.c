#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include "bitrpg.h"


VALUE cWindow;
VALUE cRenderer;
VALUE cTexture;
VALUE cSurface;


static void
window_free(void *p)
{
	if (p)
		SDL_DestroyWindow(p);
}

static void
renderer_free(void *p)
{
	if (p)
		SDL_DestroyRenderer(p);
}

static void
texture_free(void *p)
{
	if (p)
		SDL_DestroyTexture(p);
}

void
surface_free(void *p)
{
	if (p)
		SDL_FreeSurface(p);
}

VALUE
window_new(VALUE self, VALUE title, VALUE size)
{
	const char *title_str = StringValueCStr(title);
	SDL_Point size2 = from_vector(size);
	
	SDL_Window *window = SDL_CreateWindow(title_str,
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, size2.x, size2.y, 0);
	
	if (!window)
		rb_raise(rb_eRuntimeError, "Could not open window");
	
	VALUE obj = rb_data_object_alloc(self, window, NULL, window_free);
	
	// Create a window renderer
	SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, 0);
	
	if (!renderer)
		rb_raise(rb_eRuntimeError, "Could not create Renderer from window");
	
	VALUE renderer_obj = rb_data_object_alloc(cRenderer, renderer, NULL,
		renderer_free);
	rb_iv_set(obj, "@renderer", renderer_obj);
	
	return obj;
}

VALUE
window_close(VALUE self)
{
	window_free(RDATA(self)->data);
	RDATA(self)->data = NULL;
	return Qnil;
}

VALUE
window_size(VALUE self)
{
	SDL_Window *window = RDATA(self)->data;
	SDL_Point size;
	SDL_GetWindowSize(window, &size.x, &size.y);
	return to_vector(size);
}

VALUE
renderer_draw_color_set(VALUE self, VALUE color)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	SDL_Color col = to_color(color);
	SDL_SetRenderDrawColor(renderer, col.r, col.g, col.b, col.a);
	return Qnil;
}

VALUE
renderer_clear(VALUE self)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	SDL_RenderClear(renderer);
	return Qnil;
}

VALUE
renderer_present(VALUE self)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	SDL_RenderPresent(renderer);
	return Qnil;
}

VALUE
renderer_draw_rect(VALUE self, VALUE rect)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	SDL_Rect r = from_rect(rect);
	SDL_RenderFillRect(renderer, &r);
	return Qnil;
}

VALUE
renderer_zoom_set(VALUE self, VALUE zoom)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	int zoom2 = NUM2INT(zoom);
	SDL_RenderSetScale(renderer, zoom2, zoom2);
	return Qnil;
}

VALUE
renderer_copy(VALUE self, VALUE texture, VALUE position)
{
	SDL_Renderer *renderer = RDATA(self)->data;
	SDL_Texture *texture2 = RDATA(texture)->data;
	SDL_Point destpos = {0, 0};
	SDL_Rect destrect;
	
	// position
	if (position != Qnil)
	{
		destpos = from_vector(position);
	}
	
	SDL_QueryTexture(texture2, NULL, NULL, &destrect.w, &destrect.h);
	destrect.x = destpos.x;
	destrect.y = destpos.y;
	
	SDL_RenderCopy(renderer, texture2, NULL, &destrect);
	return Qnil;
}

VALUE
texture_new(VALUE self, VALUE renderer, VALUE surface, VALUE clip_rect)
{
	SDL_Renderer *renderer2 = RDATA(renderer)->data;
	SDL_Surface *surface2 = RDATA(surface)->data;
	SDL_Texture *texture;
	
	if (clip_rect != Qnil)
	{
		// TODO
		// Avoid creating a new surface for the purpose of copying a portion of
		// the original surface to a new texture.
		// See http://forums.libsdl.org/viewtopic.php?p=41215
		
		SDL_Rect rect = from_rect(clip_rect);
		SDL_Surface *clipped_surface = SDL_CreateRGBSurface(0, rect.w, rect.h,
			32, surface2->format->Rmask,
			surface2->format->Gmask, surface2->format->Bmask,
			surface2->format->Amask);
		SDL_BlitSurface(surface2, &rect, clipped_surface, NULL);
		
		texture = SDL_CreateTextureFromSurface(renderer2, clipped_surface);
		SDL_FreeSurface(clipped_surface);
	}
	else
	{
		texture = SDL_CreateTextureFromSurface(renderer2, surface2);
	}
	
	if (!texture)
		rb_raise(rb_eRuntimeError, "Could not create Texture from surface");
	
	VALUE obj = rb_data_object_alloc(self, texture, NULL, texture_free);
	return obj;
}

VALUE
surface_new(VALUE self, VALUE size)
{
	SDL_Point size2 = from_vector(size);
	SDL_Surface *surface = SDL_CreateRGBSurface(0, size2.x, size2.y,
		32, 0, 0, 0, 0);
	
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
surface_size(VALUE self)
{
	SDL_Surface *surface = RDATA(self)->data;
	SDL_Point size = {surface->w, surface->h};
	return to_vector(size);
}

void
Init_bitrpg_graphics()
{
	cWindow = rb_define_class("Window", rb_cObject);
	rb_define_singleton_method(cWindow, "new", window_new, 2);
	rb_define_method(cWindow, "close", window_close, 0);
	rb_define_method(cWindow, "size", window_size, 0);
	
	cRenderer = rb_define_class("Renderer", rb_cObject);
	rb_define_method(cRenderer, "draw_color=", renderer_draw_color_set, 1);
	rb_define_method(cRenderer, "clear", renderer_clear, 0);
	rb_define_method(cRenderer, "present", renderer_present, 0);
	rb_define_method(cRenderer, "draw_rect", renderer_draw_rect, 1);
	rb_define_method(cRenderer, "zoom=", renderer_zoom_set, 1);
	rb_define_method(cRenderer, "copy", renderer_copy, 2);
	
	cTexture = rb_define_class("Texture", rb_cObject);
	rb_define_singleton_method(cTexture, "new", texture_new, 3);
	
	cSurface = rb_define_class("Surface", rb_cObject);
	rb_define_singleton_method(cSurface, "new", surface_new, 1);
	rb_define_singleton_method(cSurface, "load", surface_load, 1);
	rb_define_method(cSurface, "size", surface_size, 0);
}