require './lib/core/tileset'
require './lib/game/state'
require './lib/game/entity'
require 'json'

class Map < State
	# The number of map tiles composing the map
	attr_reader :map_size # [Integer, Integer]
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # [Integer, Integer]
	
	attr_accessor :camera
	
	class << self
		def find(name)
			path = File.realpath("#{name}.yml", 'maps')
			data = YAML.load_file(path)
			Map.new(data)
		end
	end
	
	def initialize(data)
		@tiles = []
		@map_size = data['map_size']
		@tile_size = data['tile_size']
		
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
				
				coords = i.divmod(@map_size.x).reverse
				tile.coords = coords
				
				@tiles << tile
			end
		end
	end
	
	def add(tile, layer=1)
		@tiles << tile
	end
	
	def draw_to(target)
		center = @camera ? @camera.center : [0, 0]
		
		target_size = target.size
		offset = [center.x * @tile_size.x - target_size.x / 2,
			center.y * @tile_size.y - target_size.y / 2]
		
		target.activate
		
		# TODO
		# Combine static tile rendering with entities
		@tiles.each do |tile|
			position = [tile.coords.x * @tile_size.x - offset.x,
				tile.coords.y * @tile_size.y - offset.y]
			
			# TODO
			# Draw only if the bitmap is in the boundary
			
			tile.sprite.blit(position)
		end
	end
	
	def check_event(event)
	end
	
	def advance_frame
	end
end
