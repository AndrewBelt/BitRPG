# Combines a sprite with a coordinate position on the map
class Tile
	attr_accessor :sprite
	attr_accessor :position
	
	def initialize(sprite=nil)
		@sprite = sprite
		@position = Vector[0, 0]
	end
	
	# Simple setter for @position
	def place(x, y)
		self.position = Vector.elements([x, y])
	end
end
