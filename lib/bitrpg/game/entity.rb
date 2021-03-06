require 'bitrpg/game/tile'

# A Tile with animation and actions
class Entity < Tile
	attr_reader :type # ::Type
	attr_reader :animation # String
	attr_accessor :offset # Vector
	
	def initialize(name)
		super()
		
		@type = self.class::Type.find(name)
		raise "Could not find #{self.class} type '#{name}'" unless @type
		@offset = Vector[0, 0]
		
		self.animation = 'default'
		stop
	end
	
	def action
		if block_given?
			@action = Proc.new
		elsif @action
			@action.call
		end
	end
	
	def action?
		!!@action
	end
	
	# Position methods
	
	def hit?(position)
		@position == position
		
		# TODO
		# Support hit-testing entities larger than [1, 1]
	end
	
	def collides?
		!!@type.collides
	end
	
	# Animations
	
	def animation=(name)
		if @animation != name
			@frames = @type.animations.fetch(name)
			
			# Rewind if a different animation is requested
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
		@delay_frame = 0
	end
	
	def stop
		pause
		rewind
	end
	
	# Game loop methods
	
	def step
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
	
	def draw(renderer, position)
		super(renderer, position - @type.origin)
	end
	
	def inspect
		"\#<#{self.class}:#{@type.name}>"
	end
end


class Entity::Type
	@all = []
	
	class << self
		attr_reader :all
		
		def create(*args)
			type = self.new(*args)
			@all << type
			type
		end
		
		def find(name)
			@all.find { |t| t.name == name }
		end
	end
	
	attr_reader :name
	attr_reader :animations # {name => [sprite]}
	attr_reader :delay # Integer
	attr_reader :collides # Boolean
	
	# Pixel coordinates of the top-left corner of the sprite
	attr_reader :origin # Vector
	
	def initialize(data, tileset)
		@name = data.fetch('name', '')
		@animations = {}
		sprite_size = Vector[*data.fetch('size', [1, 1])]
		
		# 'default' animation
		tile = data['tile']
		if tile
			coords = Vector[*tile]
			@animations['default'] = [tileset.at(coords, sprite_size)]
		end
		
		# Other animations
		animations_data = data['animations']
		if animations_data
			animations_data.each do |animation_name, frames|
				@animations[animation_name] = frames.collect do |coords_ary|
					coords = Vector[*coords_ary]
					tileset.at(coords, sprite_size)
				end
			end
		end
		
		@delay = data.fetch('delay', 1)
		@origin = Vector[*data.fetch('origin', [0, 0])]
		@collides = data.fetch('collides', false)
	end
end
