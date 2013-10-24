require './lib/sprite'
require 'yaml'

class Game
	class << self
		def load(filename)
			config = YAML.load_file(filename)
			Game.new(config)
		end
	end
	
	attr_accessor :state
	alias_method :show, :state=
	
	def initialize(config)
		# Display
		
		display_conf = config['display']
		screen_size = [display_conf['width'], display_conf['height']]
		zoom = display_conf['zoom']
		
		display_size = [screen_size[0] * zoom, screen_size[1] * zoom]
		@display = Display.new(display_size)
		
		@queue = EventQueue.new
		@queue.register_display(@display)
		@queue.register_keyboard
		
		screen_bitmap = Bitmap.new(screen_size)
		@screen = Sprite.new(screen_bitmap)
		@screen.zoom = zoom
	end
	
	def run
		load './scripts/start.rb'
		
		@running = true
		while @running do
			render
			check_events
		end
		
		@display.close
		@display = nil
	end
	
	def render
		@screen.bitmap.clear
		@screen.bitmap.draw(@state)
		
		@display.clear
		@display.draw(@screen)
		@display.flip
	end
	
	def check_events
		@queue.each do |event|
			if event.type == :close
				@running = false
			end
			
			if @state
				@state.check_event(event)
			end
		end
	end
end