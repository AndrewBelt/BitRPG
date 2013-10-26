class Entity
	attr_accessor :bitmap
	attr_accessor :coords
	alias_method :place, :coords=
	
	def initialize
		@coords = [0, 0]
	end
	
	def draw_to(target, tile_size)
		target.activate
		position = [@coords.x * tile_size.x, @coords.y * tile_size.y]
		@bitmap.blit(position)
	end
	
	def advance_frame
		# TODO
		# Go to next animation
	end
	
	# TODO
	# Animations
end


class Character < Entity
	attr_accessor :behavior
	
	# TODO
	# Map walking animations
end
