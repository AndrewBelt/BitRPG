require './lib/state'
require 'json'

class Map < State
	
	def initialize
		@sprites = []
	end
	
	def load(name)
		filename = "maps/#{name}.json"
		file = File.open(filename)
		data = JSON.load(file)
		load_data(data)
	end
	
	def load_data(data)
		# p data
	end
	
	def add(sprite, layer=1)
		@sprites << sprite
	end
	
	def draw_to(target)
		@sprites.each do |sprite|
			target.draw(sprite)
		end
	end
	
	def check_event(event)
		if event.type == :keychar
			puts event.chr
		end
	end
	
	def advance_frame
		@sprites[0].move([rand(3)-1,rand(3)-1])
	end
end
