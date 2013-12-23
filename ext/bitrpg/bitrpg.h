#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <SDL/SDL.h>

SDL_Point to_point(VALUE vector);
SDL_Rect to_rect(VALUE rect);
SDL_Color to_color(VALUE color);
Uint32 to_pixel(VALUE color, const SDL_PixelFormat* format);

void surface_free(void *p);

void Init_bitrpg_native();
void Init_bitrpg_window();
void Init_bitrpg_surface();
void Init_bitrpg_event();
void Init_bitrpg_gui();

// Classes
extern VALUE cWindow;
extern VALUE cSurface;
extern VALUE cEvent;
extern VALUE mKeyboard;
extern VALUE cFont;

#endif