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
		@position = [0, 0]
		@size = @bitmap.size
	end
	
	def blit(position=[0, 0], zoom=1)
		@bitmap.blit(@position, @size, position, zoom)
	end
end
