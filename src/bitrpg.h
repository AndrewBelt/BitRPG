#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <allegro5/allegro.h>

void check_error(int error);
void soft_free(void *);
ALLEGRO_COLOR value_to_color(VALUE color);

void init_allegro();

void Init_bitrpg();
void Init_display();
void Init_graphics();
void Init_events();
void Init_gui();

#endif