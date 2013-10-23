CFLAGS = -Wall -g -O2 -std=c99 \
	-I/usr/include/ruby-2.0.0 \
	-I/usr/include/ruby-2.0.0/x86_64-linux

LDFLAGS = \
	-lallegro \
	-lallegro_main \
	-lallegro_image \
	-lallegro_color \
	-lruby

OBJS = \
	src/main.o \
	src/allegro_wrap.o \
	src/display.o \
	src/graphics.o \
	src/events.o

all: bitrpg

bitrpg: $(OBJS)
	$(LINK.c) -o $@ $^

clean:
	rm -f bitrpg
	rm -f $(OBJS)