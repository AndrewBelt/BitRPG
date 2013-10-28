require './lib/core/sprite'
require './lib/game/entity'
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
		@tile_size = data['tile_size']
		@margin = data.fetch('margin', 0)
		@spacing = data.fetch('spacing', 0)
		entities = data.fetch('entities', {})
		
		# Defaults
		@margin = 0 unless @margin
		@spacing = 0 unless @spacing
		
		size = @bitmap.size
		@sheet_size =
			[(size.x - 2 * @margin + @spacing) / (@spacing + @tile_size.x),
			 (size.y - 2 * @margin + @spacing) / (@spacing + @tile_size.y)]
		
		# TODO
		# Check validity of @sheet_size
		
		# TODO
		# Load Entities and Characters from data
		
		entities.each do |entity_name, entity_data|
			Entity::Type.all[entity_name] = Entity::Type.new(entity_data, self)
		end
	end
	
	def at(coords, size=[1, 1])
		sprite = Sprite.new(@bitmap)
		
		sprite.position = [
			@margin + (@tile_size.x + @spacing) * coords.x,
			@margin + (@tile_size.y + @spacing) * coords.y]
		
		sprite.size = [
			size.x * @tile_size.x,
			size.y * @tile_size.y]
		
		# TODO
		# Error checking
		
		sprite
	end
	
	# Returns a bitmap by index
	# The size is assumed to be [1, 1] tiles, so this is useful for
	# static map tiles.
	# In addition, bitmaps are cached for the lifetime of the tileset.
	def [](id)
		coords = id.divmod(@sheet_size.x).reverse
		at(coords)
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