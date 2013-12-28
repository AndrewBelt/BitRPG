require 'yaml'
require 'singleton'

module Game
end

class << Game
	attr_accessor :framerate # Number
	attr_reader :last_framerate # Number
	attr_accessor :root_element # Element
	attr_reader :size # Vector
	
	# Must be called before any methods of Game are used
	def load_yaml(filename)
		path = File.realpath(filename)
		data = YAML.load_file(path)
		load_hash(data)
	end
	
	def load_hash(data)
		window_conf = data.fetch('window')
		@size = Vector[window_conf.fetch('width'),
			window_conf.fetch('height')]
		@zoom = window_conf.fetch('zoom', 1)
		@framerate = window_conf.fetch('framerate', 0)
		title = window_conf.fetch('title', '')
		
		@debug = !!data['debug']
		
		window_size = @size * @zoom
		@window = Window.new(title, window_size)
		@window.renderer.zoom = @zoom
	end
	
	def renderer
		@window.renderer
	end
	
	def run
		@running = true
		
		run_script do
			Kernel::load('./scripts/start.rb')
		end
		
		@start_time = Time.now
		
		while @running do
			handle_events
			step
			render
			limit_framerate
		end
		
		# Done
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
			rescue Exception => e
				puts e
				puts e.backtrace
				stop
			end
		end
	end
	
	def script_running?
		@script_thread and @script_thread.alive?
	end
	
	def debug?
		@debug
	end
	
private
	
	def render
		renderer = renderer()
		renderer.draw_color = Color::BLACK
		renderer.clear
		
		if @root_element
			# Draw root_element to screen
			@root_element.draw(renderer, Vector[0, 0])
		end
		
		renderer.present
	end
	
	def handle_events
		Event.each do |event|
			case event.type
			when :quit
				stop
				return true
			end
			
			if @root_element
				@root_element.handle_event(event)
			end
		end
	end
	
	# The "physics" method. Changes the state of the game elements
	def step
		if @root_element
			@root_element.step
		end
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
