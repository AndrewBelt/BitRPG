#include "allegro_wrap.h"
#include <ruby.h>
#include <allegro5/allegro.h>


static VALUE event_c;


VALUE event_new(VALUE cls)
{
	rb_raise(rb_eNotImpError, "Events cannot be created directly");
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
	if (!rb_block_given_p())
		return Qnil;
	
	ALLEGRO_EVENT_QUEUE *queue = RDATA(self)->data;
	
	while (1)
	{
		ALLEGRO_EVENT *event = malloc(sizeof(event));
		int has_event = al_get_next_event(queue, event);
		
		if (!has_event)
			break;
		
		VALUE event_obj = rb_data_object_alloc(event_c, event, NULL, soft_free);
		rb_yield_values(1, event_obj);
		break;
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
	
	// rb_define_method(event_c, "ifclose", event_ifclose, 0);
	
	// class EventQueue
	
	VALUE event_queue_c = rb_define_class("EventQueue", rb_cObject);
	rb_define_singleton_method(event_queue_c, "new", event_queue_new, 0);
	
	rb_include_module(event_queue_c, rb_mEnumerable);
	rb_define_method(event_queue_c, "each", event_queue_each, 0);
	rb_define_method(event_queue_c, "register_display", event_queue_register_display, 1);
	rb_define_method(event_queue_c, "register_keyboard", event_queue_register_keyboard, 0);
}