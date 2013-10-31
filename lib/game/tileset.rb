require './lib/core/sprite'
require './lib/game/entity'
require './lib/game/character'
require 'yaml'

class Tileset
	include Enumerable
	
	attr_reader :bitmap
	attr_reader :tile_size
	attr_reader :margin
	attr_reader :spacing
	attr_reader :sheet_size
	
	# name => Tileset
	@all = {}
	
	class << self
		attr_reader :all
		
		def from_yaml(filename)
			path = File.realpath(filename)
			data = YAML.load_file(path)
			from_data(data)
		end
		
		def from_data(data)
			data.each do |name, tileset_data|
				@all[name] = Tileset.new(tileset_data)
			end
		end
	end
	
	def initialize(data)
		# Look for the bitmap relative to the 'tilesets' directory
		path = File.realpath(data['image'])
		@bitmap = Bitmap.load(path)
		@tile_size = Vector.elements(data.fetch('tile_size'))
		margin = data.fetch('margin', 0)
		spacing = data.fetch('spacing', 0)
		
		@margin = Vector[margin, margin]
		@spacing = Vector[spacing, spacing]
		
		@sheet_size = (@bitmap.size - 2 * @margin + @spacing).div(
			@spacing + @tile_size)
		
		# TODO
		# Check validity of @sheet_size
		
		entities = data.fetch('entities', {})
		entities.each do |entity_name, entity_data|
			Entity::Type.all[entity_name] = Entity::Type.new(entity_data, self)
		end
		
		characters = data.fetch('characters', {})
		characters.each do |character_name, character_data|
			Character::Type.all[character_name] =
				Character::Type.new(character_data, self)
		end
	end
	
	def at(coords, size=Vector[1, 1])
		sprite = Sprite.new(@bitmap)
		
		sprite.position = @margin + (@tile_size + @spacing).mul(@coords)
		sprite.size = @tile_size.mul(size)
		
		# TODO
		# Error checking
		
		sprite
	end
	
	# Returns a bitmap by index
	# The size is assumed to be [1, 1] tiles, so this is useful for
	# static map tiles.
	# In addition, bitmaps are cached for the lifetime of the tileset.
	def [](id)
		y, x = id.divmod(@sheet_size.x)
		at(Vector[x, y])
	end
	
	# TODO
	def object(name)
		obj = @objects[name]
		raise "Object '#{name}' not found in the tileset" unless obj
		
		coords = obj['coords']
		tiles = obj['tiles']
		at(coords, tiles)
	end
	
	def length
		@sheet_size.x * @sheet_size.y
	end
	
	def each
		length.times do |id|
			yield self[id]
		end
	end
end