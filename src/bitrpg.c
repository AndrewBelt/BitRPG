#include <stdlib.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>
#include "bitrpg.h"


void
check_error(int error)
{
	if (error)
	{
		printf("Fatal error\n");
		abort();
	}
}

void
soft_free(void *p)
{
	if (p)
		free(p);
}

void
init_allegro()
{
	al_init();
	check_error(!al_init());
	check_error(!al_init_image_addon());
	check_error(!al_install_keyboard());
	al_init_font_addon();
	al_init_ttf_addon();
	al_init_primitives_addon();
}

void
Init_bitrpg()
{
	Init_display();
	Init_graphics();
	Init_events();
	Init_gui();
}
