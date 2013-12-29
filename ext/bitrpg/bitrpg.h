#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <SDL/SDL.h>

SDL_Point from_vector(VALUE vector);
VALUE to_vector(SDL_Point point);
SDL_Rect from_rect(VALUE rect);

// TODO
// Change these to `from_*`
SDL_Color to_color(VALUE color);
Uint32 to_pixel(VALUE color, const SDL_PixelFormat* format);

void surface_free(void *p);

void Init_bitrpg_native();
void Init_bitrpg_graphics();
void Init_bitrpg_event();
void Init_bitrpg_gui();
void Init_bitrpg_audio();

// Classes
extern VALUE cWindow;
extern VALUE cRenderer;
extern VALUE cTexture;
extern VALUE cSurface;
extern VALUE cEvent;
extern VALUE mKeyboard;
extern VALUE cFont;
extern VALUE cSound;
extern VALUE cMusic;

#endif