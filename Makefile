CFLAGS = -Wall -g -O2 -std=c99 \
	-I/usr/local/include/ruby-2.0.0 \
	-I/usr/local/include/ruby-2.0.0/x86_64-darwin11.4.2

LDFLAGS = -L/usr/local/lib \
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