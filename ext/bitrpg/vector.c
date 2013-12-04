#include <ruby.h>
#include <SDL2/SDL.h>
#include "bitrpg.h"


static VALUE cVector;

VALUE
vector_new(VALUE self, VALUE x, VALUE y)
{
	SDL_Point *point = malloc(sizeof(SDL_Point));
	point->x = NUM2INT(x);
	point->y = NUM2INT(y);
	
	VALUE obj = rb_data_object_alloc(self, point, NULL, free);
	return obj;
}

VALUE vector_add(VALUE self, VALUE other)
{
	if (rb_class_of(other) != cVector)
		rb_raise(rb_eRuntimeError, "Can only add Vectors to Vectors");
	
	SDL_Point *point_self = RDATA(self)->data;
	SDL_Point *point_other = RDATA(other)->data;
	SDL_Point *point = malloc(sizeof(SDL_Point));
	point->x = point_self->x + point_other->x;
	point->y = point_self->y + point_other->y;
	
	VALUE obj = rb_data_object_alloc(cVector, point, NULL, free);
	return obj;
}

void
Init_bitrpg_vector()
{
	cVector = rb_define_class("Vector2", rb_cObject);
	rb_define_singleton_method(cVector, "new", vector_new, 2);
	rb_define_method(cVector, "+", vector_add, 1);
}