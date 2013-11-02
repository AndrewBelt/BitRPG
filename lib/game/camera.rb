class Camera
	def center
		Vector[0, 0]
	end
end


class StaticCamera < Camera
	attr_accessor :center
	
	def initialize(center=Vector[0, 0])
		@center = center
	end
end


# Follows a tile as it moves
class FollowCamera < Camera
	attr_accessor :tile
	
	def initialize(tile)
		@tile = tile
	end
	
	def center
		@tile.coords
	end
end
