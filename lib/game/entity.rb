require './lib/game/tile'

# A Tile with animation and actions
class Entity < Tile
	attr_reader :type # ::Type
	attr_reader :animation # String
	
	def initialize(name)
		super()
		
		@type = self.class::Type.all.fetch(name)
		
		self.animation = 'default'
		stop
	end
	
	def advance_frame
		@sprite = @frames[@animation_frame]
		
		if @animating and @delay_cycle.next == 0
			@animation_frame += 1
			@animation_frame %= @frames.length
		end
	end
	
	def animation=(name)
		if @animation != name
			# Reset the animation
			@frames = @type.animations.fetch(name)
			rewind
		end
		
		@animation = name
	end
	
	def play
		@animating = true
	end
	
	def pause
		@animating = false
	end
	
	def rewind
		@animation_frame = 0
		@delay_cycle = @type.delay.times.cycle
	end
	
	def stop
		pause
		rewind
	end
	
	def draw(offset)
		super(offset - @type.origin)
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
	
	# Pixel coordinates of the top-left corner of the sprite
	attr_reader :origin # Vector
	
	def initialize(data, tileset)
		size = Vector.elements(data.fetch('size', [1, 1]))
		tile_size = tileset.tile_size
		
		@animations = {}
		data['animations'].each do |animation_name, frames|
			@animations[animation_name] = frames.collect do |coords_ary|
				coords = Vector.elements(coords_ary)
				tileset.at(coords, size)
			end
		end
		
		@delay = data.fetch('delay', 1)
		@origin = Vector.elements(data.fetch('origin', [0, 0]))
	end
end

