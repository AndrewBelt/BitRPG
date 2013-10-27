require 'yaml'

class Tileset
	include Enumerable
	
	attr_reader :bitmap
	attr_reader :tile_size
	attr_reader :margin
	attr_reader :spacing
	attr_reader :sheet_size
	
	class << self
		def find(name)
			path = File.realpath("#{name}.yml", 'tilesets')
			data = YAML.load_file(path)
			Tileset.new(data)
		end
	end
	
	def initialize(data, bitmap=nil)
		# Look for the bitmap relative to the 'tilesets' directory
		@bitmap = Bitmap.find(data['image'], 'tilesets')
		
		@tile_size = data['tile_size']
		@margin = data['margin'] or 0
		@spacing = data['spacing'] or 0
		@objects = data['objects']
		
		size = @bitmap.size
		@sheet_size = [(size.x - 2 * margin + spacing) / (spacing + @tile_size.x),
			(size.y - 2 * margin + spacing) / (spacing + @tile_size.y)]
		
		# TODO
		# Check validity of @sheet_size
		
		@cached_bitmaps = {}
	end
	
	def at(coords, tiles=[1, 1])
		position = [@margin + (@tile_size.x + @spacing) * coords.x,
			@margin + (@tile_size.y + @spacing) * coords.y]
		size = [tiles.x * @tile_size.x, tiles.y * @tile_size.y]
		
		# TODO
		# Error checking
		
		@bitmap.clip(position, size)
	end
	
	# Returns a bitmap by index
	# The size is assumed to be [1, 1] tiles, so this is useful for
	# static map tiles.
	# In addition, bitmaps are cached until the tileset is garbage
	# collected, so don't use this if the tileset is to be persisted.
	def [](id)
		cached_bitmap = @cached_bitmaps[id]
		return cached_bitmap if cached_bitmap
		
		coords = id.divmod(@sheet_size.x).reverse
		
		clipped_bitmap = at(coords)
		@cached_bitmaps[id] = clipped_bitmap
		clipped_bitmap
	end
	
	def object(name)
		obj = @objects[name]
		raise "Object '#{name}' not found in the tileset" unless obj
		
		coords = obj['coords']
		tiles = obj['size']
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