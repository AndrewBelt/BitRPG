# A basic object to be displayed on the map
class Tile
	attr_accessor :bitmap
	attr_accessor :coords
	alias_method :place, :coords=
	
	def initialize
		@coords = [0, 0]
	end
end


# A tile with animation
class Entity < Tile
	# def self.find(name)
	# 	path = File.realpath("#{name}.yml", 'entities')
	# 	data = YAML.load_file(path)
	# 	Entity.new(data)
	# end
	
	def initialize(data)
		super()
		
		tileset_name = data['tileset']
		object_name = data['object']
		
		tileset = Tileset.find(tileset_name)
		@bitmap = tileset.object(object_name)
		
		# TODO
		# Decide on a schema for the data
		
		# TEMP
		# @animations = {
		# 	'open' => [Bitmap.new, Bitmap.new],
		# 	'close' => [Bitmap.new, Bitmap.new],
		# }
		# @current_animation
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
