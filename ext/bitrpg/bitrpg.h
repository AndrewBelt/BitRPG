#ifndef BITRPG_H
#define BITRPG_H

#include <ruby.h>
#include <SDL/SDL.h>

Uint32 color_to_rgba(VALUE color, const SDL_PixelFormat* format);

void Init_bitrpg_native();
void Init_bitrpg_window();
void Init_bitrpg_surface();
void Init_bitrpg_event();
void Init_bitrpg_gui();

#endif