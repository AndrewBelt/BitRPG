require './lib/game/entity'

# An entity with the ability to walk
class Character < Entity
	attr_accessor :behavior
	
	def initialize(*args)
		super
		
		@face_direction = :down
	end
	
	# Walking
	
	VELOCITIES = {
		:up => [0, -1],
		:down => [0, 1],
		:left => [-1, 0],
		:right => [1, 0]
	}
	
	def advance_frame
		super
		
		# if @behavior and !@curr_direction
		# 	@behavior.behave(self)
		# end
		
		if @next_direction and !@curr_direction
			@face_direction = @next_direction
			
			# TODO
			# Check collision
			
			@curr_direction = @next_direction
			@prev_position = @position
			@walk_frame = 0
			
			@next_direction = nil
			
			update_walk_animation
		end
		
		if @curr_direction
			velocity = VELOCITIES[@curr_direction]
			prop_offset = @walk_frame.to_f / @type.slowness
			
			if prop_offset >= 1
				# Done walking
				prop_offset = 1
				@position = [@prev_position.x + velocity.x,
					@prev_position.y + velocity.y]
				
				@curr_direction = nil
				@prev_position = nil
				@walk_frame = nil
				
				update_walk_animation
			else
				offset = [prop_offset * velocity.x, prop_offset * velocity.y]
				@position = [@prev_position.x + offset.x,
					@prev_position.y + offset.y]
				@walk_frame += 1
			end
		end
	end
	
	def walk(direction)
		@next_direction = direction
	end
	
	def update_walk_animation
		animation_name = @face_direction.to_s
		self.animation = animation_name
		
		if @curr_direction
			play
		else
			stop
		end
	end
end


class Character::Type < Entity::Type
	@all = {}
	
	attr_reader :slowness
	
	def initialize(data, tileset)
		super
		
		@slowness = data.fetch('slowness', 1)
	end
end
