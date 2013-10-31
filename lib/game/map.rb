require './lib/game/tileset'
require './lib/game/state'
require './lib/game/entity'
require './lib/game/behavior'
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
		
		@map_size = Vector[data.fetch('map_size')]
		@tile_size = Vector[data.fetch('tile_size')]
		
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
			
			gids.each_index do |i|
				gid = gids[i]
				# gid of 0 means a blank space
				next if gid == 0
				
				tile = Tile.new
				
				fid = first_gids.find {|fid| fid <= gid}
				id = gid - fid
				tileset = tilesets[fid]
				tile.sprite = tileset[id]
				
				position_y, position_x = i.divmod(@map_size.x)
				tile.position = Vector[position_x, position_y]
				
				@map_tiles << tile
			end
		end
	end
	
	def add(entity, layer=1)
		@entities << entity
	end
	
	# Returns a sorted list of all Tiles, Entities, Characters, etc
	# for rendering
	def all_tiles
		# TODO
		# Sort by z-order
		
		@map_tiles + @entities
	end
	
	def draw_to(target)
		center = @camera ? @camera.center : [0, 0]
		
		target_size = target.size
		offset = [center.x * @tile_size.x - target_size.x / 2,
			center.y * @tile_size.y - target_size.y / 2]
		
		target.activate
		
		# TODO
		# Combine static tile rendering with entities
		all_tiles.each do |tile|
			position = [tile.position.x * @tile_size.x - offset.x,
				tile.position.y * @tile_size.y - offset.y]
			
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
