# Combines a sprite with a coordinate position on the map
class Tile
	attr_accessor :sprite # Sprite
	attr_accessor :position # Vector
	attr_accessor :layer # Integer
	
	def initialize(sprite=nil)
		@sprite = sprite
		@position = Vector[0, 0]
		@layer = 1
	end
	
	# Simple setter for @position
	def place(x, y)
		@position = Vector[x, y]
	end
	
	def draw(renderer, position)
		@sprite.draw(renderer, position)
	end
	
	def <=>(other)
		cmp = @layer <=> other.layer
		return cmp if cmp != 0
		@position <=> other.position
	end
end
