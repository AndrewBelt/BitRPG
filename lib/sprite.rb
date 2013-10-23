class Sprite
	attr_accessor :bitmap # Bitmap
	attr_accessor :position # [Number, Number]
	attr_accessor :zoom # Integer
	
	def initialize
		@position = [0, 0]
		@zoom = 1
	end
	
	def draw_to(target)
		target.activate
		@bitmap.blit(@position, @zoom)
	end
	
	def move(delta_position)
		@position[0] += delta_position[0]
		@position[1] += delta_position[1]
	end
end
