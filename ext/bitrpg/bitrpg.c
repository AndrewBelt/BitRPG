#include <ruby.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include "bitrpg.h"


void
Init_bitrpg_native()
{
	Init_bitrpg_vector();
	Init_bitrpg_window();
	Init_bitrpg_surface();
	Init_bitrpg_event();
	Init_bitrpg_gui();
	
	// Initialize SDL
	SDL_Init(SDL_INIT_VIDEO);
	IMG_Init(IMG_INIT_PNG);
}