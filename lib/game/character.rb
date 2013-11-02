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
		:up =>    Vector[0, -1],
		:down =>  Vector[0, 1],
		:left =>  Vector[-1, 0],
		:right => Vector[1, 0]
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
				@position = @prev_position + velocity
				
				@curr_direction = nil
				@prev_position = nil
				@walk_frame = nil
				
				update_walk_animation
			else
				offset = prop_offset * velocity
				@position = @prev_position + offset
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
