require 'core/sprite'
require 'yaml'

module Game
end

class << Game
	attr_accessor :framerate
	attr_reader :last_framerate
	attr_accessor :root_element
	attr_reader :size
	
	# Must be called before any methods of Game are used
	def from_yaml(filename)
		path = File.realpath(filename)
		data = YAML.load_file(path)
		from_data(data)
	end
	
	def from_data(data)
		# Display
		
		display_conf = data.fetch('display')
		size_ary = [display_conf.fetch('width'),
			display_conf.fetch('height')]
		@size = Vector.elements(size_ary)
		@zoom = display_conf.fetch('zoom', 1)
		@framerate = display_conf.fetch('framerate', 0)
		
		display_size = @size * @zoom
		@display = Display.new(display_size)
		
		@queue = EventQueue.new
		@queue.register_display(@display)
		@queue.register_keyboard
		
		screen_bitmap = Bitmap.new(@size)
		@screen = Sprite.new(screen_bitmap)
	end
	
	def run
		@running = true
		
		run_script do
			Kernel::load './scripts/start.rb'
		end
		
		@start_time = Time.now
		
		while @running do
			handle_events
			step
			render
			limit_framerate
		end
		
		# Cleanup
		@display.close
		@display = nil
	end
	
	def stop
		@running = false
		nil
	end
	
	alias_method :quit, :stop
	alias_method :close, :stop
	
	def show(element)
		@root_element = element
	end
	
	# Runs the given block on a unique thread
	# If a script is already running, raises an exception
	# unless fail_silently is true.
	def run_script(fail_silently=false)
		if script_running?
			raise 'Script thread already running' unless fail_silently
			return
		end
		
		@script_thread = Thread.new do
			begin
				yield
			rescue => e
				puts e
				puts e.backtrace
				stop
			end
		end
	end
	
	def script_running?
		@script_thread and @script_thread.alive?
	end
	
private
	
	def render
		@display.clear
		
		if @root_element
			@screen.bitmap.activate
			@screen.bitmap.clear
			@root_element.draw(Vector[0, 0])
			
			@display.activate
			@screen.draw(Vector[0, 0], @zoom)
		end
		
		@display.flip
	end
	
	def handle_events
		@queue.each do |event|
			if event.type == :close
				stop
				next
			end
			
			if @root_element
				@root_element.handle_event(event)
			end
		end
	end
	
	# The "physics" method. Changes the state of the game elements
	def step
		@root_element.step if @root_element
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
end
