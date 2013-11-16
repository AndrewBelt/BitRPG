CFLAGS = -Wall -g -O2 -std=c99 \
	-Wl,-rpath,lib \
	-I/usr/include/ruby-2.0.0 \
	-I/usr/include/ruby-2.0.0/x86_64-linux

LDFLAGS = -L/usr/local/lib \
	-Llib \
	-lallegro \
	-lallegro_main \
	-lallegro_image \
	-lallegro_color \
	-lallegro_font \
	-lallegro_ttf \
	-lallegro_primitives \
	-lruby

OBJS = \
	src/main.o \
	src/bitrpg.o \
	src/display.o \
	src/graphics.o \
	src/events.o \
	src/gui.o

STATIC_LIBS =

all: bin/bitrpg

bin/bitrpg: $(OBJS)
	$(LINK.c) -o $@ $^ $(STATIC_LIBS)

clean:
	rm -f bin/bitrpg
	rm -f $(OBJS)
