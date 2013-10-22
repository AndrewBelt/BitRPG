CFLAGS = -Wall -g -O3 -std=c99 \
	-I/usr/local/include/ruby-2.0.0 \
	-I/usr/local/include/ruby-2.0.0/x86_64-darwin11.4.2

LDFLAGS = \
	-lallegro.5.0 \
	-lallegro_main.5.0 \
	-lallegro_image.5.0 \
	-lallegro_color.5.0 \
	-lruby.2.0

OBJS = \
	src/main.o \
	src/display.o \
	src/bitmap.o

all: bitrpg

bitrpg: $(OBJS)
	$(LINK.c) -o $@ $^

clean:
	rm -f bitrpg
	rm -f $(OBJS)