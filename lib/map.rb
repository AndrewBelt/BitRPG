require './lib/state'
require 'json'

class Map < State
	
	def initialize
		@sprites = []
	end
	
	def load(filename)
		file = File.open(filename)
		data = JSON.load(file)
		load_data(data)
	end
	
	def load_data(data)
		# p data
	end
	
	def add(sprite, layer=1)
		p @sprites
		@sprites << sprite
	end
	
	def draw_to(target)
		@sprites.each do |sprite|
			target.draw(sprite)
		end
	end
	
	def check_event(event)
		if event.type == :keydown
			puts event.keycode
		end
	end
end
