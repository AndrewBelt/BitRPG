require './lib/core/sprite'
require 'yaml'

class Game
	class << self
		def load(filename)
			config = YAML.load_file(filename)
			Game.new(config)
		end
	end
	
	attr_accessor :last_framerate
	attr_accessor :state
	alias_method :show, :state=
	
	def initialize(config)
		# Display
		
		display_conf = config['display']
		screen_size = [display_conf['width'], display_conf['height']]
		zoom = display_conf['zoom']
		@framerate = display_conf['framerate']
		
		display_size = [screen_size.x * zoom, screen_size.y * zoom]
		@display = Display.new(display_size)
		
		@queue = EventQueue.new
		@queue.register_display(@display)
		@queue.register_keyboard
		
		# Create screen
		screen_bitmap = Bitmap.new(screen_size)
		@screen = Sprite.new(screen_bitmap)
		@screen.zoom = zoom
	end
	
	def run
		# The script thread
		# script_thread = Thread.new do
		# 	load './scripts/start.rb'
		# end
		load './scripts/start.rb'
		
		@running = true
		# script_thread.run
		@start_time = Time.now
		
		while @running do
			render
			limit_framerate
			check_events
			advance_frame
		end
		
		@display.close
		@display = nil
	end
	
	def stop
		@running = false
	end
	
	alias_method :quit, :stop
	alias_method :close, :stop
	
	def render
		@display.clear
		
		if @state
			@screen.bitmap.clear
			@screen.bitmap.draw(@state)
			@display.draw(@screen)
		end
		
		@display.flip
	end
	
	def limit_framerate
		current_time = Time.now
		
		if @start_time
			duration = current_time - @start_time
			sleep_time = 1.0 / @framerate - duration
			sleep(sleep_time) if sleep_time > 0
		end
		
		end_time = Time.now
		@last_framerate = 1 / (end_time - @start_time)
		@start_time = end_time
	end
	
	def check_events
		@queue.each do |event|
			stop if event.type == :close
			@state.check_event(event) if @state
		end
	end
	
	def advance_frame
		@state.advance_frame if @state
	end
end
