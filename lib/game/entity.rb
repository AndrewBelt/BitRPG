require './lib/game/tile'

# A Tile with animation and actions
class Entity < Tile
	attr_reader :type
	
	def initialize(name)
		super()
		
		@type = self.class::Type.all.fetch(name)
		
		self.animation = 'default'
		stop
	end
	
	def advance_frame
		if @animating and @delay_cycle.next == 0
			@sprite = @animation_cycle.next
		end
	end
	
	# Resets the animation
	def animation=(name)
		@delay_cycle = @type.delay.times.cycle
		@animation_cycle = @type.animations.fetch(name).cycle
		@sprite = @animation_cycle.next
	end
	
	def play
		@animating = true
	end
	
	def stop
		@animating = false
	end
	
	def action
		if block_given?
			@action = Proc.new
		else
			@action.call if @action
		end
	end
end


class Entity::Type
	@all = {}
	
	class << self
		attr_reader :all
	end
	
	attr_reader :animations # {name => [sprite]}
	attr_reader :delay # Integer
	
	# Map coordinates of the center of the entity
	# The default is half the size, i.e. the center
	# of the bounding box.
	# For use with the FollowCamera, for example.
	attr_reader :origin # [Number, Number]
	
	def initialize(data, tileset)
		size = data.fetch('size', [1, 1])
		
		@animations = {}
		data['animations'].each do |animation_name, frames|
			@animations[animation_name] = frames.collect do |coords|
				tileset.at(coords, size)
			end
		end
		
		@delay = data.fetch('delay', 1)
		@origin = data['origin']
		
		unless @origin
			@origin = [size.x.to_f / 2, size.y.to_f / 2]
		end
	end
end

