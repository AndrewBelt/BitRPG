# Mutable container of two Vectors defining the top-left position and size
class Rect
	attr_accessor :position # Vector
	attr_accessor :size # Vector
	
	def initialize(position=Vector.new, size=Vector.new)
		@position = position
		@size = size
	end
	
	def include?(vec)
		@position.x <= vec.x and vec.x < @position.x + @size.x and
			@position.y <= vec.y and vec.y < @position.y + @size.y
	end
	
	def overlaps?(rect)
		# Lower level than fancy vector addition, but somewhat faster
		@position.x <= rect.position.x + rect.size.x and
			@position.y <= rect.position.y + rect.size.y and
			rect.position.x < @position.x + @size.x and
			rect.position.y < @position.y + @size.y
	end
	
	# Returns a new Rect shifted by the Vector
	def shift(vec)
		Rect.new(@position + vec, @size)
	end
	
	# Returns a new Rect which has been moved to the closest position
	# inside the given Rect
	def constrain(boundary)
		rect = clone
		
		if rect.position.x < boundary.position.x
			rect.position = Vector[boundary.position.x, rect.position.y]
		end
		if rect.position.y < boundary.position.y
			rect.position = Vector[rect.position.x, boundary.position.y]
		end
		
		# TODO
		# Too lazy to make complete this
		
		rect
	end
end