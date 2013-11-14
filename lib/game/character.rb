require 'game/constants'
require 'game/entity'
require 'game/behavior'
require 'thread'

# An entity with the ability to walk
class Character < Entity
	attr_accessor :behavior
	
	def initialize(*args)
		super
		
		@face_direction = :down
		@walk_mutex = Mutex.new
		@walk_resource = ConditionVariable.new
	end
	
	# Walking
	
	def step(map)
		
		# Override the next direction if the behavior has one
		if @behavior and !@curr_direction
			@next_direction ||= @behavior.next_direction
		end
		
		# Potentially begin walking
		if !@curr_direction and @next_direction
			@face_direction = @next_direction
			
			# Check collision
			if map.collides?(face_position)
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
	
	def walk(direction, blocking=true)
		@next_direction = direction
		
		if blocking
			@walk_mutex.synchronize do
				@walk_resource.wait(@walk_mutex)
			end
		end
		
		nil
	end
	
	def walking?
		@curr_direction
	end
	
	def face_position
		@position + DIRECTIONS[@face_direction]
	end
	
private
	
	def finish_walk
		@walk_mutex.synchronize do
			@walk_resource.broadcast
		end
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
