#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <allegro5/allegro.h>

void soft_free(void *);
ALLEGRO_COLOR color_map(VALUE color);

void Init_bitrpg();
void Init_display();
void Init_graphics();
void Init_events();
void Init_gui();

#endif