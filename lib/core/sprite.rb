# Similar to a clipped Bitmap (see Bitmap#clip), but
# it references the original Bitmap
class Sprite
	attr_accessor :bitmap # Bitmap
	
	# The sprite represents the entire Bitmap if either
	# of these are nil.
	attr_accessor :position # [Integer, Integer]
	attr_accessor :size # [Integer, Integer]
	
	def initialize(bitmap)
		@bitmap = bitmap
		@position = Vector[0, 0]
		@size = @bitmap.size
	end
	
	def blit(x=0, y=0, zoom=1)
		@bitmap.blit(position.x, position.y, size.x, size.y, x, y, zoom)
	end
end
