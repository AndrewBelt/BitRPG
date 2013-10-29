# Combines a sprite with a coordinate position on the map
class Tile
	attr_accessor :sprite
	attr_accessor :position
	
	def initialize
		@position = [0, 0]
	end
	
	def place(x, y)
		self.position = [x, y]
	end
end
