require './lib/sprite'
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
		# TODO
		# Maybe load this in a new thread
		load './scripts/start.rb'
		
		@running = true
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
	
	def render
		@screen.bitmap.clear
		@screen.bitmap.draw(@state)
		
		@display.clear
		@display.draw(@screen)
		@display.flip
	end
	
	def limit_framerate
		current_time = Time.now
		
		if @start_time
			duration = current_time - @start_time
			puts 1 / duration
			sleep_time = 1.0 / @framerate - duration
			sleep(sleep_time) if sleep_time > 0
		end
		
		end_time = Time.now
		@last_framerate = 1 / (end_time - @start_time)
		@start_time = end_time
		
		puts '%.2f fps' % @last_framerate
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
	
	def advance_frame
		if @state
			@state.advance_frame
		end
	end
end