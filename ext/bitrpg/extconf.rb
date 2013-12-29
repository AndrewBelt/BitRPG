require 'mkmf'

# Custom
$CFLAGS << ' -g -Wall -O3'
$LDFLAGS << ' -lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer'

create_makefile('bitrpg_native')
