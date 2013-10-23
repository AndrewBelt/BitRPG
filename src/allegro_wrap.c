#include "allegro_wrap.h"
#include <stdlib.h>


void soft_free(void *p)
{
	if (p)
		free(p);
}


void Init_allegro_wrap()
{
	Init_display();
	Init_graphics();
	Init_events();
}
