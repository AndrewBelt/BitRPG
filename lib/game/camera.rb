class Camera
	def center
		Vector[0, 0]
	end
end


class FixedCamera < Camera
	attr_accessor :center
	
	def initialize(center=Vector[0, 0])
		@center = center
	end
end


# Follows an entity as it moves
class FollowCamera < Camera
	attr_accessor :entity
	
	def initialize(entity)
		@entity = entity
	end
	
	def center
		@entity.position
	end
end
