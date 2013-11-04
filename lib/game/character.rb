require './lib/game/constants'
require './lib/game/entity'
require './lib/game/behavior'
require 'thread'

# An entity with the ability to walk
class Character < Entity
	attr_accessor :behavior
	
	def initialize(*args)
		super
		
		@walk_offset = Vector[0, 0]
		@face_direction = :down
		@walk_mutex = Mutex.new
		@walk_resource = ConditionVariable.new
	end
	
	# Walking
	
	def advance_frame
		# Override the next direction if the behavior has one
		if !@curr_direction and @behavior
			@next_direction ||= @behavior.next_direction
		end
		
		# Request a new current direction from the behavior
		if !@curr_direction and @next_direction
			@face_direction = @next_direction
			
			# TODO
			# Check collision
			new_position = @position + DIRECTIONS[@next_direction]
			collides = new_position.x < 0 || new_position.y < 0
			
			if collides
				@next_direction = nil
			else
				@curr_direction, @next_direction = @next_direction, nil
				@walk_frame = 1
			end
		end
		
		if @curr_direction
			delta_position = DIRECTIONS[@curr_direction]
			
			if @walk_frame >= @type.slowness
				# Done walking
				
				@curr_direction = nil
				@walk_frame = 0
				
				@position += delta_position
				@walk_offset = Vector[0, 0]
				
				@walk_mutex.synchronize do
					@walk_resource.broadcast
				end
			else
				@walk_offset = delta_position * @walk_frame.to_f / @type.slowness
				@walk_frame += 1
			end
		end
		
		# TODO
		# Should this be called every frame or only when the walk animation
		# actually needs to be changed?
		update_walk_animation
		
		super
	end
	
	def position
		super + @walk_offset
	end
	
	def position=(pos)
		super
		@walk_offset = Vector[0, 0]
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
	
	def update_walk_animation
		animation_name = @face_direction.to_s
		self.animation = animation_name
		
		if @curr_direction
			play
		else
			stop
		end
	end
	
	private :update_walk_animation
end


class Character::Type < Entity::Type
	@all = {}
	
	attr_reader :slowness
	
	def initialize(data, tileset)
		super
		
		@slowness = data.fetch('slowness', 1)
	end
end
