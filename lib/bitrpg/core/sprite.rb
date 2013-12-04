# Represents a portion of a surface
class Sprite
	attr_accessor :surface # Surface
	attr_accessor :clip_rect # Rect
	attr_accessor :zoom # Integer
	
	# The sprite covers the entire surface by default
	def initialize(surface=nil)
		@surface = surface
		@clip_rect = Rect.new(Vector[0, 0], @surface.size)
		@zoom = 1
	end
	
	def draw_to(dest_surface, position)
		dest_surface.blit(@surface, @clip_rect, position, @zoom)
	end
	
	def size
		@clip_rect.size
	end
end
