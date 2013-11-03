# Similar to a clipped Bitmap (see Bitmap#clip), but
# it references the original Bitmap
class Sprite
	attr_accessor :bitmap # Bitmap
	
	# The sprite represents the entire Bitmap if either
	# of these are nil.
	attr_accessor :clip_position # Vector
	attr_accessor :clip_size # Vector
	
	def initialize(bitmap)
		@bitmap = bitmap
		@clip_position = Vector[0, 0]
		@clip_size = @bitmap.size
	end
	
	def draw(position, zoom=1)
		@bitmap.blit(clip_position.x, clip_position.y,
			clip_size.x, clip_size.y, position.x, position.y, zoom)
	end
end
