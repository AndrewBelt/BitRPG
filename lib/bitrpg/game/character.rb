require 'thread'
require 'bitrpg/game/constants'
require 'bitrpg/game/entity'

# An entity with the ability to walk
class Character < Entity
	def initialize(*args)
		super
		
		@face_direction = :down
		@next_direction = nil
		@walk_mutex = Mutex.new
		@walk_resource = ConditionVariable.new
	end
	
	# Walking
	
	def walk(direction)
		# Face direction
		if direction.y < 0
			@next_direction = :up
		elsif direction.y > 0
			@next_direction = :down
		elsif direction.x < 0
			@next_direction = :left
		elsif direction.x > 0
			@next_direction = :right
		end
		
		# Move character
		velocity = direction.normalize / @type.slowness.to_f
		@position += velocity
	end
	
	def step
		if MAP.collides?(Vector[@position.x.floor, @position.y.round])
			@position = Vector[@position.x.floor + 1, @position.y]
		end
		
		# Refresh animation
		if @next_direction
			self.animation = @next_direction.to_s
			play
		else
			stop
		end
		@next_direction = nil
		
		super
		return
		
		# Potentially begin walking
		if !@curr_direction and @next_direction
			@face_direction = @next_direction
			
			# Check collision
			if Map.instance.collides?(face_position)
				@next_direction = nil
				finish_walk
			else
				# Begin walking
				@curr_direction = @next_direction
				@next_direction = nil
				
				@walk_frame = 0
			end
		end
		
		# Update the animation
		if @face_direction != @last_face_direction
			animation_name = @face_direction.to_s
			self.animation = animation_name
		end
		
		if @last_direction != @curr_direction
			if @curr_direction
				play
				@animation_frame += 1
			else
				stop
			end
		end
		
		@last_direction = @curr_direction
		@last_face_direction = @face_direction
		
		# Potentially finish walking
		if @curr_direction
			delta_position = DIRECTIONS[@curr_direction]
			@walk_frame += 1
			
			if @walk_frame >= @type.slowness
				# Finish walking
				
				finish_walk
				@curr_direction = nil
				@walk_frame = 0
				
				@position += delta_position
				@offset = Vector[0, 0]
			else
				walk_prop = @walk_frame.to_f / @type.slowness
				@offset = delta_position * walk_prop
			end
		end
		
		super
	end
	
	def face_position
		@position.round + DIRECTIONS[@face_direction]
	end
end


class Character::Type < Entity::Type
	@all = []
	
	attr_reader :slowness
	
	def initialize(data, tileset)
		super
		@slowness = data.fetch('slowness', 1)
	end
end
