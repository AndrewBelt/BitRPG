#include <ruby.h>
#include <SDL2/SDL.h>
#include "bitrpg.h"


VALUE cWindow;

static void
window_free(void *p)
{
	if (p)
	{
		SDL_DestroyWindow(p);
	}
}

VALUE
window_new(VALUE self, VALUE title, VALUE size)
{
	const char *title_str = StringValueCStr(title);
	int w = NUM2INT(rb_funcall(size, rb_intern("x"), 0));
	int h = NUM2INT(rb_funcall(size, rb_intern("y"), 0));
	
	SDL_Window *window = SDL_CreateWindow(title_str,
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, w, h, 0);
	
	if (!window)
		rb_raise(rb_eRuntimeError, "Could not open window");
	
	VALUE obj = rb_data_object_alloc(self, window, NULL, window_free);
	
	// Allocate a surface with no free function
	SDL_Surface *surface = SDL_GetWindowSurface(window);
	VALUE cSurface = rb_const_get(rb_cObject, rb_intern("Surface"));
	VALUE surface_obj = rb_data_object_alloc(cSurface, surface, NULL, NULL);
	rb_iv_set(obj, "@surface", surface_obj);
	return obj;
}

VALUE
window_destroy(VALUE self)
{
	window_free(RDATA(self)->data);
	RDATA(self)->data = NULL;
	return Qnil;
}

VALUE
window_update(VALUE self)
{
	SDL_Window *window = RDATA(self)->data;
	SDL_UpdateWindowSurface(window);
	return Qnil;
}

void
Init_bitrpg_window()
{
	cWindow = rb_define_class("Window", rb_cObject);
	rb_define_singleton_method(cWindow, "new", window_new, 2);
	rb_define_method(cWindow, "destroy", window_destroy, 0);
	rb_define_method(cWindow, "update", window_update, 0);
}