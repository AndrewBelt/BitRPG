#include <stdlib.h>
#include "bitrpg.h"


void soft_free(void *p)
{
	if (p)
		free(p);
}

void Init_bitrpg()
{
	Init_display();
	Init_graphics();
	Init_events();
	Init_gui();
}
