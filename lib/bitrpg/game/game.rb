require 'yaml'
require 'singleton'

class Game
	include Singleton
	attr_accessor :framerate # Number
	attr_reader :last_framerate # Number
	attr_accessor :root_element # Element
	
	# Must be called before any methods of Game are used
	def from_yaml(filename)
		path = File.realpath(filename)
		data = YAML.load_file(path)
		from_data(data)
	end
	
	def from_data(data)
		window_conf = data.fetch('window')
		screen_size = Vector[window_conf.fetch('width'),
			window_conf.fetch('height')]
		zoom = window_conf.fetch('zoom', 1)
		@framerate = window_conf.fetch('framerate', 0)
		title = window_conf.fetch('title', '')
		
		window_size = screen_size * zoom
		@window = Window.new(title, window_size)
		
		screen_surface = Surface.new(screen_size)
		@screen = Sprite.new(screen_surface)
		@screen.zoom = zoom
	end
	
	def rect
		@screen.clip_rect
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
		@window.destroy
		@window = nil
	end
	
	def stop
		@running = false
		nil
	end
	
	alias_method :quit, :stop
	alias_method :close, :stop
	alias_method :exit, :stop
	
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
		@window.surface.fill(nil, Color::BLACK)
		
		if @root_element
			# Draw root_element to screen
			@screen.surface.fill(nil, Color::BLACK)
			@root_element.draw_to(@screen.surface, rect)
			
			# Draw screen to window
			@screen.blit(@window.surface, Vector.new)
		end
		
		@window.update
	end
	
	def handle_events
		Event.each do |event|
			p event
			
			case event.type
			when :quit
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
