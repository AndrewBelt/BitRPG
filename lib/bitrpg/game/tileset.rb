require 'yaml'
require 'bitrpg/game/entity'
require 'bitrpg/game/character'

class Tileset
	include Enumerable
	
	attr_reader :texture # Texture
	attr_reader :tile_size # Vector
	attr_reader :margin # Vector
	attr_reader :spacing # Vector
	attr_reader :sheet_size # Vector
	
	# name => Tileset
	@all = {}
	
	class << self
		attr_reader :all
		
		def load_yaml(filename)
			path = File.realpath(filename)
			data = YAML.load_file(path)
			load(data)
		end
		
		def load(data)
			data.each do |name, tileset_data|
				@all[name] = Tileset.new(tileset_data)
			end
		end
	end
	
	def initialize(data)
		# Look for the surface relative to the 'tilesets' directory
		path = File.realpath(data['image'])
		@surface = Surface.load(path)
		@tile_size = Vector[*data.fetch('tile_size')]
		margin = data.fetch('margin', 0)
		spacing = data.fetch('spacing', 0)
		
		@margin = Vector[margin, margin]
		@spacing = Vector[spacing, spacing]
		
		sheet_rect = @surface.size - @margin * 2 + @spacing
		tile_rect = @tile_size + @spacing
		@sheet_size = sheet_rect / tile_rect
		
		# TODO
		# Check validity of @sheet_size
		
		entities = data.fetch('entities', {})
		entities.each do |name, entity_data|
			entity_data['name'] = name
			Entity::Type.create(entity_data, self)
		end
		
		characters = data.fetch('characters', {})
		characters.each do |name, character_data|
			character_data['name'] = name
			Character::Type.create(character_data, self)
		end
	end
	
	def at(coords, sprite_size=Vector[1, 1])
		sprite = Sprite.new(@surface)
		
		tile_rect = @tile_size + @spacing
		sprite.clip_rect = Rect.new(@margin + tile_rect * coords,
			@tile_size * sprite_size)
		
		# TODO
		# Error checking
		
		sprite
	end
	
	# Returns a surface by index
	# The size is assumed to be [1, 1] tiles, so this is useful for
	# static map tiles.
	# In addition, surfaces are cached for the lifetime of the tileset.
	def [](id)
		y, x = id.divmod(@sheet_size.x)
		at(Vector[x, y])
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