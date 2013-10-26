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
		{
			VALUE chr = rb_enc_uint_chr(
				event->keyboard.unichar, utf8_encoding);
			rb_iv_set(obj, "@chr", chr);
		}
		rb_iv_set(obj, "@repeat", event->keyboard.repeat ? Qtrue : Qfalse);
		
	case ALLEGRO_EVENT_KEY_DOWN:
	case ALLEGRO_EVENT_KEY_UP:
		rb_iv_set(obj, "@keycode", INT2NUM(event->keyboard.keycode));
		break;
	}
	
	return obj;
}

void Init_events()
{
	rb_require("./lib/events");
	
	// class EventQueue
	
	VALUE event_queue_c = rb_const_get(rb_cObject, rb_intern("EventQueue"));
	rb_define_singleton_method(event_queue_c, "new", event_queue_new, 0);
	
	rb_define_method(event_queue_c, "each", event_queue_each, 0);
	rb_define_method(event_queue_c, "register_display", event_queue_register_display, 1);
	rb_define_method(event_queue_c, "register_keyboard", event_queue_register_keyboard, 0);
	
	// class Event
	
	VALUE event_c = rb_const_get(rb_cObject, rb_intern("Event"));
	
	VALUE event_types = rb_hash_new();
	
	#define EVENT_TYPE(key, value) \
		rb_hash_aset(event_types, INT2NUM(key), ID2SYM(rb_intern(value)))
	
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_AXIS, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_BUTTON_UP, "");
	// EVENT_TYPE(ALLEGRO_EVENT_JOYSTICK_CONFIGURATION, "");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_DOWN, "keydown");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_CHAR, "keychar");
	EVENT_TYPE(ALLEGRO_EVENT_KEY_UP, "keyup");
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
	
	// Globals
	
	utf8_encoding = rb_enc_find("UTF8");
}