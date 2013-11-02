require './lib/game/state'
require './lib/game/tileset'
require './lib/game/entity'
require './lib/game/behavior'
require './lib/game/camera'
require 'yaml'

class Map < State
	# The number of map tiles composing the map
	attr_reader :map_size # [Integer, Integer]
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # [Integer, Integer]
	
	attr_reader :map_tiles
	attr_reader :entities
	
	attr_accessor :player
	attr_accessor :camera
	
	class << self
		def find(name)
			path = File.realpath("#{name}.yml", 'maps')
			data = YAML.load_file(path)
			Map.new(data)
		end
	end
	
	def initialize(data)
		@map_tiles = []
		@entities = []
		
		@map_size = Vector.elements(data.fetch('map_size'))
		@tile_size = Vector.elements(data.fetch('tile_size'))
		
		# Load tilesets
		
		# first_gid => Tileset
		tilesets = {}
		
		data['tilesets'].each do |first_gid, tileset_name|
			tilesets[first_gid] = Tileset.all[tileset_name]
		end
		
		first_gids = tilesets.keys.reverse
		
		# Load layers
		
		data['layers'].each do |layer, gids|
			# TODO
			# Handle collision layers properly
			next if layer == 'collision'
			
			gids.each_index do |index|
				gid = gids[index]
				# gid of 0 means a blank space
				next if gid == 0
				
				fid = first_gids.find {|fid| fid <= gid}
				id = gid - fid
				tileset = tilesets[fid]
				tile = Tile.new(tileset[id])
				
				position_y, position_x = index.divmod(@map_size.x)
				tile.position = Vector[position_x, position_y]
				
				@map_tiles << tile
			end
		end
		
		# Set up camera crew
		
		@camera = Camera.new
	end
	
	def add(entity, layer=1)
		@entities << entity
	end
	
	# Returns a sorted list of all Tiles, Entities, Characters, etc
	# for rendering
	def all_tiles
		# TODO
		# Sort by z-order
		
		tiles = []
		tiles += @map_tiles
		tiles += @entities
		tiles
	end
	
	def draw_to(target)
		center = @camera.center
		offset = @tile_size.mul(center) - target.size / 2
		
		target.activate
		
		# TODO
		# Combine static tile rendering with entities
		all_tiles.each do |tile|
			position = @tile_size.mul(tile.position) - offset
			
			# TODO
			# Draw only if the bitmap is in the boundary
			
			tile.sprite.blit(position)
		end
	end
	
	def check_event(event)
		if event.type == :key_down
			if [:up, :down, :left, :right].include?(event.key)
				@player.walk(event.key) if @player
			end
		end
	end
	
	def advance_frame
		@entities.each do |entity|
			entity.advance_frame
		end
	end
end
