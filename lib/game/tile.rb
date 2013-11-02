# Combines a sprite with a coordinate position on the map
class Tile
	# Only drawable on Maps
	include Drawable
	
	attr_accessor :sprite
	attr_accessor :position
	
	def initialize(sprite=nil)
		@sprite = sprite
		@position = Vector[0, 0]
	end
	
	# Simple setter for @position
	def place(x, y)
		@position = Vector.elements([x, y])
	end
end
