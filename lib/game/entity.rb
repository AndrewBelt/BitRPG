# A basic object to be displayed on the map
class Tile
	attr_accessor :sprite
	attr_accessor :coords
	alias_method :place, :coords=
	
	# TODO
	# Replace Bitmap#sub with the following accessors
	
	# If nil, the entire bitmap is drawn
	# attr_accessor :bitmap_position
	# attr_accessor :bitmap_size
	
	def initialize
		@coords = [0, 0]
	end
end


# A tile with animation
class Entity < Tile
	
	class Type
		@all = {}
		
		class << self
			attr_reader :all
		end
		
		attr_reader :animations # {name => [sprite]}
		
		def initialize(data, tileset)
			size = data.fetch('size', [1, 1])
			
			@animations = {}
			data['animations'].each do |animation_name, frames|
				@animations[animation_name] = frames.collect do |coords|
					tileset.at(coords, size)
				end
			end
			
			p @animations
		end
		
		def default_sprite
			@animations['default'].first
		end
	end
	
	attr_reader :type
	
	def initialize(name)
		super()
		
		@type = Entity::Type.all[name]
		@sprite = @type.default_sprite
	end
	
	def advance_frame
		# TODO
	end
	
	# TODO
	# Animations
end


# An entity with the ability to walk
class Character < Entity
	attr_accessor :behavior
	
	# TODO
	# Map walking animations
end
