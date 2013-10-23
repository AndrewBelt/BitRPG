#include "allegro_wrap.h"
#include <ruby.h>
#include <ruby/encoding.h>
#include <allegro5/allegro.h>


static VALUE event_c;
static rb_encoding *utf8_encoding;


VALUE event_new(VALUE cls)
{
	rb_raise(rb_eNotImpError, "Events cannot be created directly");
}


VALUE event_ifclose(VALUE self)
{
	ALLEGRO_EVENT *event = RDATA(self)->data;
	
	if (event->type == ALLEGRO_EVENT_DISPLAY_CLOSE)
		rb_yield(Qnil);
	
	return Qnil;
}


VALUE event_ifkeydown(VALUE self)
{
	ALLEGRO_EVENT *event = RDATA(self)->data;
	
	if (event->type == ALLEGRO_EVENT_KEY_DOWN)
	{
		// TODO
		// Convert these to symbols
		
		VALUE keycode = INT2NUM(event->keyboard.keycode);
		rb_yield(keycode);
	}
	
	return Qnil;
}


VALUE event_ifkeychar(VALUE self)
{
	ALLEGRO_EVENT *event = RDATA(self)->data;
	
	if (event->type == ALLEGRO_EVENT_KEY_CHAR)
	{
		VALUE unichar = rb_enc_uint_chr(event->keyboard.unichar, utf8_encoding);
		VALUE keycode = INT2NUM(event->keyboard.keycode);
		VALUE repeat = event->keyboard.repeat ? Qtrue : Qfalse;
		rb_yield_values(3, unichar, keycode, repeat);
	}
	
	return Qnil;
}


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
	
	
	while (1)
	{
		ALLEGRO_EVENT event;
		int has_event = al_get_next_event(queue, &event);
		
		if (!has_event)
			break;
		
		// Copy the event into heap-allocated memory until this
		// forum post is resolved.
		// https://www.allegro.cc/forums/thread/613411
		ALLEGRO_EVENT *event_p = malloc(sizeof(ALLEGRO_EVENT));
		memcpy(event_p, &event, sizeof(ALLEGRO_EVENT));
		VALUE event_obj = rb_data_object_alloc(event_c, event_p, NULL, soft_free);
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


void Init_events()
{
	// class Event
	
	event_c = rb_define_class("Event", rb_cObject);
	rb_define_singleton_method(event_c, "new", event_new, 0);
	
	rb_define_method(event_c, "ifclose", event_ifclose, 0);
	rb_define_method(event_c, "ifkeydown", event_ifkeydown, 0);
	rb_define_method(event_c, "ifkeychar", event_ifkeychar, 0);
	
	// class EventQueue
	
	VALUE event_queue_c = rb_define_class("EventQueue", rb_cObject);
	rb_define_singleton_method(event_queue_c, "new", event_queue_new, 0);
	
	rb_include_module(event_queue_c, rb_mEnumerable);
	rb_define_method(event_queue_c, "each", event_queue_each, 0);
	rb_define_method(event_queue_c, "register_display", event_queue_register_display, 1);
	rb_define_method(event_queue_c, "register_keyboard", event_queue_register_keyboard, 0);
	
	utf8_encoding = rb_enc_find("UTF8");
}