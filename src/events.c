#include "allegro_wrap.h"
#include <ruby.h>
#include <ruby/encoding.h>
#include <allegro5/allegro.h>

static rb_encoding *utf8_encoding;
static ID event_types[48];

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
	rb_iv_set(obj, "@type", event_types[event->type]);
	
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
	// class EventQueue
	
	VALUE event_queue_c = rb_define_class("EventQueue", rb_cObject);
	rb_define_singleton_method(event_queue_c, "new", event_queue_new, 0);
	
	rb_include_module(event_queue_c, rb_mEnumerable);
	rb_define_method(event_queue_c, "each", event_queue_each, 0);
	rb_define_method(event_queue_c, "register_display", event_queue_register_display, 1);
	rb_define_method(event_queue_c, "register_keyboard", event_queue_register_keyboard, 0);
	
	// Globals
	
	utf8_encoding = rb_enc_find("UTF8");
	
	// event type symbols
	
	/*
	event_types[ALLEGRO_EVENT_JOYSTICK_AXIS]			= rb_intern("joystick_axis");
	event_types[ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN]		= rb_intern("joystick_button_down");
	event_types[ALLEGRO_EVENT_JOYSTICK_BUTTON_UP]		= rb_intern("joystick_button_up");
	event_types[ALLEGRO_EVENT_JOYSTICK_CONFIGURATION]	= rb_intern("joystick_configuration");
	*/
	event_types[ALLEGRO_EVENT_KEY_DOWN]					= rb_intern("keydown");
	event_types[ALLEGRO_EVENT_KEY_CHAR]					= rb_intern("keychar");
	event_types[ALLEGRO_EVENT_KEY_UP]					= rb_intern("keyup");
	/*
	event_types[ALLEGRO_EVENT_MOUSE_AXES]				= rb_intern("");
	event_types[ALLEGRO_EVENT_MOUSE_BUTTON_DOWN]		= rb_intern("");
	event_types[ALLEGRO_EVENT_MOUSE_BUTTON_UP]			= rb_intern("");
	event_types[ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY]		= rb_intern("");
	event_types[ALLEGRO_EVENT_MOUSE_LEAVE_DISPLAY]		= rb_intern("");
	event_types[ALLEGRO_EVENT_MOUSE_WARPED]				= rb_intern("");
	*/
	event_types[ALLEGRO_EVENT_TIMER]					= rb_intern("timer");
	event_types[ALLEGRO_EVENT_DISPLAY_EXPOSE]			= rb_intern("expose");
	event_types[ALLEGRO_EVENT_DISPLAY_RESIZE]			= rb_intern("resize");
	event_types[ALLEGRO_EVENT_DISPLAY_CLOSE]			= rb_intern("close");
	event_types[ALLEGRO_EVENT_DISPLAY_LOST]				= rb_intern("lost");
	event_types[ALLEGRO_EVENT_DISPLAY_FOUND]			= rb_intern("found");
	event_types[ALLEGRO_EVENT_DISPLAY_SWITCH_IN]		= rb_intern("switch_in");
	event_types[ALLEGRO_EVENT_DISPLAY_SWITCH_OUT]		= rb_intern("switch_out");
	event_types[ALLEGRO_EVENT_DISPLAY_ORIENTATION]		= rb_intern("orientation");
}