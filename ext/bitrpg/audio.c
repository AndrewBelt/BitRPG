#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include "bitrpg.h"


VALUE cSound;
VALUE cMusic;


static void
music_free(void *p)
{
	if (p)
		Mix_FreeMusic(p);
}

static void
sound_free(void *p)
{
	if (p)
		Mix_FreeChunk(p);
}

VALUE
sound_load(VALUE self, VALUE filename)
{
	const char *filename_str = StringValueCStr(filename);
	Mix_Chunk *chunk = Mix_LoadWAV(filename_str);
	
	if (!chunk)
		rb_raise(rb_eRuntimeError, "Could not load sound '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(self, chunk, NULL, sound_free);
	return obj;
}

VALUE
sound_play(VALUE self)
{
	Mix_Chunk *chunk = RDATA(self)->data;
	Mix_PlayChannel(-1, chunk, 0);
	return Qnil;
}

VALUE
music_load(VALUE self, VALUE filename)
{
	const char *filename_str = StringValueCStr(filename);
	Mix_Music *music = Mix_LoadMUS(filename_str);
	
	if (!music)
		rb_raise(rb_eRuntimeError, "Could not load music '%s'", filename_str);
	
	VALUE obj = rb_data_object_alloc(self, music, NULL, music_free);
	return obj;
}

VALUE
music_play(int argc, VALUE *argv, VALUE self)
{
	Mix_Music *music = RDATA(self)->data;
	
	// fade_in (seconds)
	if (argc >= 1)
	{
		double fade_in = NUM2DBL(argv[0]);
		Mix_FadeInMusic(music, -1, (int) (fade_in * 1000));
	}
	else
	{
		Mix_PlayMusic(music, -1);
	}
	
	return Qnil;
}

VALUE
music_stop(VALUE cls)
{
	Mix_HaltMusic();
	return Qnil;
}

VALUE
music_pause(VALUE cls)
{
	Mix_PauseMusic();
	return Qnil;
}

VALUE
music_resume(VALUE cls)
{
	Mix_ResumeMusic();
	return Qnil;
}

VALUE
music_playing(VALUE cls)
{
	return Mix_PlayingMusic() ? Qtrue : Qfalse;
}

void
Init_bitrpg_audio()
{
	int err;
	Mix_Init(MIX_INIT_OGG);
	err = Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024);
	
	if (err)
		rb_raise(rb_eRuntimeError, "Could not initialize audio");
	
	// class Sound
	cSound = rb_define_class("Sound", rb_cObject);
	rb_define_singleton_method(cSound, "load", sound_load, 1);
	rb_define_method(cSound, "play", sound_play, 0);
	
	// class Music
	cMusic = rb_define_class("Music", rb_cObject);
	rb_define_singleton_method(cMusic, "load", music_load, 1);
	rb_define_method(cMusic, "play", music_play, -1);
	rb_define_singleton_method(cMusic, "stop", music_stop, 0);
	rb_define_singleton_method(cMusic, "pause", music_pause, 0);
	rb_define_singleton_method(cMusic, "resume", music_resume, 0);
	rb_define_singleton_method(cMusic, "playing?", music_playing, 0);
}