#include <ruby.h>
#include <ruby/encoding.h>
#include <allegro5/allegro.h>
#include "bitrpg.h"

static rb_encoding *utf8_encoding;

VALUE event_create(ALLEGRO_EVENT *event);


void event_queue_free(void *p)
{
	if (p)
		al_destroy_event_queue(p);
}

VALUE event_queue_new(VALUE cls)
{
	ALLEGRO_EVENT_QUEUE *queue = al_create_event_queue();
	
	VALUE obj = rb_data_object_alloc(cls, queue, NULL, event_queue_free);
	return obj;
}

VALUE event_queue_each(VALUE self)
{
	ALLEGRO_EVENT_QUEUE *queue = RDATA(self)->data;
	ALLEGRO_EVENT event;
	
	while (al_get_next_event(queue, &event))
	{
		VALUE event_obj = event_create(&event);
		rb_yield_values(1, event_obj);
	}
	
	return Qnil;
}

VALUE event_queue_register_display(VALUE self, VALUE display)
{
	ALLEGRO_EVENT_QUEUE *queue = RDATA(self)->data;
	ALLEGRO_DISPLAY *d = RDATA(display)->data;
	al_register_event_source(queue, al_get_display_event_source(d));
	return Qnil;
}

VALUE event_queue_register_keyboard(VALUE self)
{
	ALLEGRO_EVENT_QUEUE *queue = RDATA(self)->data;
	al_register_event_source(queue, al_get_keyboard_event_source());
	return Qnil;
}

VALUE event_create(ALLEGRO_EVENT *event)
{
	VALUE event_c = rb_const_get(rb_cObject, rb_intern("Event"));
	VALUE obj = rb_obj_alloc(event_c);
	
	// Set the event type
	VALUE event_types = rb_iv_get(event_c, "@event_types");
	VALUE type = rb_hash_aref(event_types, INT2NUM(event->type));
	rb_iv_set(obj, "@type", type);
	
	switch (event->type)
	{
	case ALLEGRO_EVENT_KEY_CHAR:
		rb_iv_set(obj, "@chr", rb_enc_uint_chr(event->keyboard.unichar,
			utf8_encoding));
		rb_iv_set(obj, "@repeat", event->keyboard.repeat ? Qtrue : Qfalse);
		
	case ALLEGRO_EVENT_KEY_DOWN:
	case ALLEGRO_EVENT_KEY_UP:
		{
			VALUE key_codes = rb_iv_get(event_c, "@key_codes");
			VALUE key_code = INT2NUM(event->keyboard.keycode);
			VALUE key_code_sym = rb_hash_aref(key_codes, key_code);
			rb_iv_set(obj, "@key", key_code_sym);
		}
		break;
	}
	
	return obj;
}

void Init_events()
{
	rb_require("./lib/core/events");
	
	// class EventQueue
	
	VALUE event_queue_c = rb_const_get(rb_cObject, rb_intern("EventQueue"));
	rb_define_singleton_method(event_queue_c, "new", event_queue_new, 0);
	
	rb_define_method(event_queue_c, "each", event_queue_each, 0);
	rb_define_method(event_queue_c, "register_display", event_queue_register_display, 1);
	rb_define_method(event_queue_c, "register_keyboard", event_queue_register_keyboard, 0);
	
	// class Event
	
	VALUE event_c = rb_const_get(rb_cObject, rb_intern("Event"));
	
	VALUE event_types = rb_hash_new();
	#define EVENT_TYPE(type, symbol) \
		rb_hash_aset(event_types, INT2NUM(type), ID2SYM(rb_intern(symbol)))
	
	// TODO
	// Fill out the rest of these
	
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_AXIS, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_BUTTON_UP, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_CONFIGURATION, "");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_DOWN, "key_down");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_CHAR, "key_char");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_UP, "key_up");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_AXES, "");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_BUTTON_DOWN, "");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_BUTTON_UP, "");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY, "");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_LEAVE_DISPLAY, "");
	// EVENT_TYPE(ALLEGRO_EVENT_MOUSE_WARPED, "");
	EVENT_TYPE(ALLEGRO_EVENT_TIMER, "timer");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_EXPOSE, "expose");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_RESIZE, "resize");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_CLOSE, "close");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_LOST, "lost");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_FOUND, "found");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_SWITCH_IN, "switch_in");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_SWITCH_OUT, "switch_out");
	EVENT_TYPE(ALLEGRO_EVENT_DISPLAY_ORIENTATION, "orientation");
	
	rb_iv_set(event_c, "@event_types", event_types);
	
	
	VALUE key_codes = rb_hash_new();
	#define KEY_CODE(key, symbol) \
		rb_hash_aset(key_codes, INT2NUM(key), ID2SYM(rb_intern(symbol)))
	
	char sym_alphabet[] = "a";
	for (int key = ALLEGRO_KEY_A; key <= ALLEGRO_KEY_Z; key++, sym_alphabet[0]++)
		KEY_CODE(key, sym_alphabet);
	
	char sym_num[] = "num0";
	for (int key = ALLEGRO_KEY_0; key <= ALLEGRO_KEY_9; key++, sym_num[3]++)
		KEY_CODE(key, sym_num);
	
	char sym_pad[] = "pad0";
	for (int key = ALLEGRO_KEY_PAD_0; key <= ALLEGRO_KEY_PAD_9; key++, sym_pad[3]++)
		KEY_CODE(key, sym_pad);
	
	char sym_fn[] = "f1";
	for (int key = ALLEGRO_KEY_F1; key <= ALLEGRO_KEY_F9; key++, sym_fn[1]++)
		KEY_CODE(key, sym_fn);
	
	KEY_CODE(ALLEGRO_KEY_F10, "f10");
	KEY_CODE(ALLEGRO_KEY_F11, "f11");
	KEY_CODE(ALLEGRO_KEY_F12, "f12");
	KEY_CODE(ALLEGRO_KEY_ESCAPE, "escape");
	KEY_CODE(ALLEGRO_KEY_TILDE, "tilde");
	KEY_CODE(ALLEGRO_KEY_MINUS, "minus");
	KEY_CODE(ALLEGRO_KEY_EQUALS, "equals");
	KEY_CODE(ALLEGRO_KEY_BACKSPACE, "backspace");
	KEY_CODE(ALLEGRO_KEY_TAB, "tab");
	KEY_CODE(ALLEGRO_KEY_OPENBRACE, "open_brace");
	KEY_CODE(ALLEGRO_KEY_CLOSEBRACE, "close_brace");
	KEY_CODE(ALLEGRO_KEY_ENTER, "enter");
	KEY_CODE(ALLEGRO_KEY_SEMICOLON, "semicolon");
	KEY_CODE(ALLEGRO_KEY_QUOTE, "quote");
	KEY_CODE(ALLEGRO_KEY_BACKSLASH, "backslash");
	// KEY_CODE(ALLEGRO_KEY_BACKSLASH2, "");
	// KEY_CODE(ALLEGRO_KEY_COMMA, "");
	// KEY_CODE(ALLEGRO_KEY_FULLSTOP, "");
	// KEY_CODE(ALLEGRO_KEY_SLASH, "");
	KEY_CODE(ALLEGRO_KEY_SPACE, "space");
	// KEY_CODE(ALLEGRO_KEY_INSERT, "");
	// KEY_CODE(ALLEGRO_KEY_DELETE, "");
	// KEY_CODE(ALLEGRO_KEY_HOME, "");
	// KEY_CODE(ALLEGRO_KEY_END, "");
	// KEY_CODE(ALLEGRO_KEY_PGUP, "");
	// KEY_CODE(ALLEGRO_KEY_PGDN, "");
	KEY_CODE(ALLEGRO_KEY_LEFT, "left");
	KEY_CODE(ALLEGRO_KEY_RIGHT, "right");
	KEY_CODE(ALLEGRO_KEY_UP, "up");
	KEY_CODE(ALLEGRO_KEY_DOWN, "down");
	// KEY_CODE(ALLEGRO_KEY_PAD_SLASH, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_ASTERISK, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_MINUS, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_PLUS, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_DELETE, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_ENTER, "");
	// KEY_CODE(ALLEGRO_KEY_PRINTSCREEN, "");
	// KEY_CODE(ALLEGRO_KEY_PAUSE, "");
	// KEY_CODE(ALLEGRO_KEY_ABNT_C1, "");
	// KEY_CODE(ALLEGRO_KEY_YEN, "");
	// KEY_CODE(ALLEGRO_KEY_KANA, "");
	// KEY_CODE(ALLEGRO_KEY_CONVERT, "");
	// KEY_CODE(ALLEGRO_KEY_NOCONVERT, "");
	// KEY_CODE(ALLEGRO_KEY_AT, "");
	// KEY_CODE(ALLEGRO_KEY_CIRCUMFLEX, "");
	// KEY_CODE(ALLEGRO_KEY_COLON2, "");
	// KEY_CODE(ALLEGRO_KEY_KANJI, "");
	// KEY_CODE(ALLEGRO_KEY_LSHIFT, "");
	// KEY_CODE(ALLEGRO_KEY_RSHIFT, "");
	// KEY_CODE(ALLEGRO_KEY_LCTRL, "");
	// KEY_CODE(ALLEGRO_KEY_RCTRL, "");
	// KEY_CODE(ALLEGRO_KEY_ALT, "");
	// KEY_CODE(ALLEGRO_KEY_ALTGR, "");
	// KEY_CODE(ALLEGRO_KEY_LWIN, "");
	// KEY_CODE(ALLEGRO_KEY_RWIN, "");
	// KEY_CODE(ALLEGRO_KEY_MENU, "");
	// KEY_CODE(ALLEGRO_KEY_SCROLLLOCK, "");
	// KEY_CODE(ALLEGRO_KEY_NUMLOCK, "");
	// KEY_CODE(ALLEGRO_KEY_CAPSLOCK, "");
	// KEY_CODE(ALLEGRO_KEY_PAD_EQUALS, "");
	// KEY_CODE(ALLEGRO_KEY_BACKQUOTE, "");
	// KEY_CODE(ALLEGRO_KEY_SEMICOLON2, "");
	// KEY_CODE(ALLEGRO_KEY_COMMAND, "");
	
	rb_iv_set(event_c, "@key_codes", key_codes);
	
	
	// Globals
	
	utf8_encoding = rb_enc_find("UTF8");
}