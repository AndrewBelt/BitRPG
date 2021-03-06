#include <ruby.h>
#include <SDL2/SDL.h>
#include "bitrpg.h"


VALUE cEvent;
VALUE mKeyboard;


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
			VALUE scan_codes = rb_iv_get(mKeyboard, "@scan_codes");
			VALUE scan_code = INT2FIX(event->key.keysym.scancode);
			VALUE key = rb_hash_aref(scan_codes, scan_code);
			rb_iv_set(obj, "@key", key);
			break;
		}
		case SDL_TEXTINPUT:
		{
			VALUE text = rb_str_new_cstr(event->text.text);
			rb_iv_set(obj, "@text", text);
			break;
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

/*
VALUE
keyboard_held(VALUE self, VALUE key_sym)
{
	VALUE scan_codes = rb_iv_get(mKeyboard, "@scan_codes");
	VALUE scan_code = rb_funcall(scan_codes, rb_intern("key"), 1, key_sym);
	
	if (scan_code == Qnil)
		return Qfalse;
	
	const Uint8 *state = SDL_GetKeyboardState(NULL);
	return state[FIX2INT(scan_code)] ? Qtrue : Qfalse;
}
*/

static const Uint8 *keyboard_state;

static int
keyboard_held_each(VALUE key, VALUE val, VALUE held_keys)
{
	if (keyboard_state[FIX2INT(key)])
	{
		rb_ary_push(held_keys, val);
	}
	
	return ST_CONTINUE;
}

VALUE
keyboard_held(VALUE self)
{
	VALUE scan_codes = rb_iv_get(mKeyboard, "@scan_codes");
	keyboard_state = SDL_GetKeyboardState(NULL);
	
	VALUE held_keys = rb_ary_new();
	rb_hash_foreach(scan_codes, keyboard_held_each, held_keys);
	return held_keys;
}

void
Init_bitrpg_event()
{
	// Event
	
	cEvent = rb_define_class("Event", rb_cObject);
	rb_define_singleton_method(cEvent, "each", event_each, 0);
	
	VALUE event_types = rb_hash_new();
	#define EVENT_TYPE(type, symbol) \
		rb_hash_aset(event_types, INT2FIX(type), ID2SYM(rb_intern(symbol)))
	
	EVENT_TYPE(SDL_QUIT, "quit");
	EVENT_TYPE(SDL_KEYDOWN, "key_down");
	EVENT_TYPE(SDL_KEYUP, "key_up");
	EVENT_TYPE(SDL_TEXTINPUT, "text");
	
	rb_iv_set(cEvent, "@event_types", event_types);
	
	// Keyboard
	
	mKeyboard = rb_define_module("Keyboard");
	
	rb_define_singleton_method(mKeyboard, "held", keyboard_held, 0);
	
	VALUE scan_codes = rb_hash_new();
	#define SCAN_CODE(scan_code, symbol) \
		rb_hash_aset(scan_codes, INT2FIX(scan_code), ID2SYM(rb_intern(symbol)))
	
	SCAN_CODE(SDL_SCANCODE_0, "num0");
	SCAN_CODE(SDL_SCANCODE_1, "num1");
	SCAN_CODE(SDL_SCANCODE_2, "num2");
	SCAN_CODE(SDL_SCANCODE_3, "num3");
	SCAN_CODE(SDL_SCANCODE_4, "num4");
	SCAN_CODE(SDL_SCANCODE_5, "num5");
	SCAN_CODE(SDL_SCANCODE_6, "num6");
	SCAN_CODE(SDL_SCANCODE_7, "num7");
	SCAN_CODE(SDL_SCANCODE_8, "num8");
	SCAN_CODE(SDL_SCANCODE_9, "num9");
	SCAN_CODE(SDL_SCANCODE_A, "a");
	SCAN_CODE(SDL_SCANCODE_B, "b");
	SCAN_CODE(SDL_SCANCODE_C, "c");
	SCAN_CODE(SDL_SCANCODE_D, "d");
	SCAN_CODE(SDL_SCANCODE_E, "e");
	SCAN_CODE(SDL_SCANCODE_F, "f");
	SCAN_CODE(SDL_SCANCODE_G, "g");
	SCAN_CODE(SDL_SCANCODE_H, "h");
	SCAN_CODE(SDL_SCANCODE_I, "i");
	SCAN_CODE(SDL_SCANCODE_J, "j");
	SCAN_CODE(SDL_SCANCODE_K, "k");
	SCAN_CODE(SDL_SCANCODE_L, "l");
	SCAN_CODE(SDL_SCANCODE_M, "m");
	SCAN_CODE(SDL_SCANCODE_N, "n");
	SCAN_CODE(SDL_SCANCODE_O, "o");
	SCAN_CODE(SDL_SCANCODE_P, "p");
	SCAN_CODE(SDL_SCANCODE_Q, "q");
	SCAN_CODE(SDL_SCANCODE_R, "r");
	SCAN_CODE(SDL_SCANCODE_S, "s");
	SCAN_CODE(SDL_SCANCODE_T, "t");
	SCAN_CODE(SDL_SCANCODE_U, "u");
	SCAN_CODE(SDL_SCANCODE_V, "v");
	SCAN_CODE(SDL_SCANCODE_W, "w");
	SCAN_CODE(SDL_SCANCODE_X, "x");
	SCAN_CODE(SDL_SCANCODE_Y, "y");
	SCAN_CODE(SDL_SCANCODE_Z, "z");
	SCAN_CODE(SDL_SCANCODE_SPACE, "space");
	SCAN_CODE(SDL_SCANCODE_UP, "up");
	SCAN_CODE(SDL_SCANCODE_DOWN, "down");
	SCAN_CODE(SDL_SCANCODE_LEFT, "left");
	SCAN_CODE(SDL_SCANCODE_RIGHT, "right");
	SCAN_CODE(SDL_SCANCODE_RETURN, "return");
	SCAN_CODE(SDL_SCANCODE_BACKSPACE, "backspace");
	SCAN_CODE(SDL_SCANCODE_DELETE, "delete");
	
	rb_iv_set(mKeyboard, "@scan_codes", scan_codes);
}