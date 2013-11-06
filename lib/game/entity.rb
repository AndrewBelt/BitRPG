require './lib/game/tile'

# A Tile with animation and actions
class Entity < Tile
	attr_reader :type # ::Type
	attr_reader :animation # String
	attr_accessor :offset # Vector
	
	def initialize(name)
		super()
		
		@type = self.class::Type.all.fetch(name)
		@offset = Vector[0, 0]
		
		self.animation = 'default'
		stop
	end
	
	def action
		if block_given?
			@action = Proc.new
		else
			@action.call if @action
		end
	end
	
	# Position methods
	
	def position
		super + @offset
	end
	
	def position=(pos)
		super
		@offset = Vector[0, 0]
	end
	
	def hit?(position)
		hits = (@position == position)
		# TODO
		# Support hit-testing entities larger than [1, 1]
		hits
	end
	
	def collides?
		@type.collides
	end
	
	# Animations
	
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
		@delay_frame = 0
	end
	
	def pause
		@animating = false
		@delay_frame = 0
	end
	
	def rewind
		@animation_frame = 0
		@delay_frame = 0
	end
	
	def stop
		pause
		rewind
	end
	
	# Game loop methods
	
	def step(map)
		if @animating
			if @delay_frame >= @type.delay
				@animation_frame += 1
				@animation_frame %= @frames.length
				
				@delay_frame = 0
			end
		end
		
		@sprite = @frames[@animation_frame]
		
		if @animating
			@delay_frame += 1
		end
	end
	
	def draw(offset)
		super(offset - @type.origin)
	end
end


class Entity::Type
	@all = {}
	
	class << self
		attr_reader :all
	end
	
	attr_reader :animations # {name => [sprite]}
	attr_reader :delay # Integer
	attr_reader :collides # Boolean
	
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
		@collides = data.fetch('collides', false)
	end
end

