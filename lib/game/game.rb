require './lib/core/sprite'
require 'yaml'

module Game
end

class << Game
	attr_accessor :framerate
	attr_reader :last_framerate
	attr_accessor :state
	alias_method :show, :state=
	
	# Must be called before any methods of Game are used
	def from_yaml(filename)
		path = File.realpath(filename)
		data = YAML.load_file(path)
		from_data(data)
	end
	
	def from_data(data)
		# Display
		
		display_conf = data.fetch('display')
		screen_size_ary = [display_conf.fetch('width'),
			display_conf.fetch('height')]
		screen_size = Vector.elements(screen_size_ary)
		@zoom = display_conf.fetch('zoom', 1)
		@framerate = display_conf.fetch('framerate', 0)
		
		display_size = screen_size * @zoom
		@display = Display.new(display_size)
		
		@queue = EventQueue.new
		@queue.register_display(@display)
		@queue.register_keyboard
		
		screen_bitmap = Bitmap.new(screen_size)
		@screen = Sprite.new(screen_bitmap)
	end
	
	def run
		@running = true
		
		# The script thread
		@script_thread = Thread.new do
			begin
				Kernel::load './scripts/start.rb'
			rescue => e
				puts e
				puts e.backtrace
				@running = false
			end
		end
		
		@start_time = Time.now
		
		while @running do
			render
			limit_framerate
			check_events
			advance_frame
		end
		
		# Cleanup
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
			@display.activate
			@screen.blit(Vector[0, 0], @zoom)
		end
		
		@display.flip
	end
	
	def limit_framerate
		current_time = Time.now
		
		if @framerate > 0 and @start_time
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
