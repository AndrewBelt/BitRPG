#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <SDL/SDL.h>

SDL_Color color_to_pixel(VALUE color);
Uint32 color_to_rgba(VALUE color, const SDL_PixelFormat* format);

void surface_free(void *p);

void Init_bitrpg_native();
void Init_bitrpg_window();
void Init_bitrpg_surface();
void Init_bitrpg_event();
void Init_bitrpg_gui();

// Defined classes
extern VALUE cWindow;
extern VALUE cSurface;
extern VALUE cEvent;
extern VALUE cFont;

#endif