#include <ruby.h>
#include <SDL2/SDL.h>
#include "bitrpg.h"


VALUE cEvent;

VALUE
event_create(const SDL_Event *event)
{
	VALUE obj = rb_obj_alloc(cEvent);
	
	// Set event type
	VALUE event_types = rb_iv_get(cEvent, "@event_types");
	VALUE type = rb_hash_aref(event_types, INT2FIX(event->type));
	rb_iv_set(obj, "@type", type);
	
	// Set type-specific info
	switch (event->type)
	{
	case SDL_KEYDOWN:
	case SDL_KEYUP:
		{
			rb_iv_set(obj, "@repeat", event->key.repeat ? Qtrue : Qfalse);
			VALUE key_codes = rb_iv_get(cEvent, "@key_codes");
			VALUE key_code = INT2FIX(event->key.keysym.sym);
			VALUE key = rb_hash_aref(key_codes, key_code);
			rb_iv_set(obj, "@key", key);
		}
	}
	
	return obj;
}

VALUE
event_each(VALUE self)
{
	SDL_Event event;
	
	while (SDL_PollEvent(&event))
	{
		VALUE event_obj = event_create(&event);
		rb_yield_values(1, event_obj);
	}
	
	return Qnil;
}

void
Init_bitrpg_event()
{
	cEvent = rb_define_class("Event", rb_cObject);
	rb_define_singleton_method(cEvent, "each", event_each, 0);
	
	// event_types
	
	VALUE event_types = rb_hash_new();
	#define EVENT_TYPE(type, symbol) \
		rb_hash_aset(event_types, INT2FIX(type), ID2SYM(rb_intern(symbol)))
	
	EVENT_TYPE(SDL_QUIT, "quit");
	EVENT_TYPE(SDL_KEYDOWN, "key_down");
	EVENT_TYPE(SDL_KEYUP, "key_up");
	
	rb_iv_set(cEvent, "@event_types", event_types);
	
	// key_codes
	
	VALUE key_codes = rb_hash_new();
	#define KEY_CODE(key, symbol) \
		rb_hash_aset(key_codes, INT2NUM(key), ID2SYM(rb_intern(symbol)))
	
	KEY_CODE(SDLK_UP, "up");
	KEY_CODE(SDLK_DOWN, "down");
	KEY_CODE(SDLK_LEFT, "left");
	KEY_CODE(SDLK_RIGHT, "right");
	KEY_CODE(SDLK_SPACE, "space");
	
	rb_iv_set(cEvent, "@key_codes", key_codes);
}