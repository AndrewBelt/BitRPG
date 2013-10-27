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
	
	def initialize
		clear
	end
	
	def clear
		@tiles = []
		@map_size = [0, 0]
		@tile_size = [0, 0]
	end
	
	def load(name)
		path = File.realpath("#{name}.json", 'maps')
		data = JSON.load(File.open(path))
		load_data(data)
	end
	
	def load_data(data)
		clear()
		
		unless data['orientation'] == 'orthogonal'
			raise 'Only orthoganal maps are supported'
		end
		
		@map_size = [data['width'], data['height']]
		@tile_size = [data['tilewidth'], data['tileheight']]
		
		# Load tilesets
		
		tilesets = {}
		
		data['tilesets'].each do |tileset_data|
			name = tileset_data['name']
			next if name == 'collision'
			
			image_filename = tileset_data['image']
			image_size = [tileset_data['imagewidth'], tileset_data['imageheight']]
			tile_size = [tileset_data['tilewidth'], tileset_data['tileheight']]
			margin = tileset_data['margin']
			spacing = tileset_data['spacing']
			
			tileset_bitmap = Bitmap.find(image_filename)
			
			unless tileset_bitmap.size == image_size
				raise "Tileset '#{name}' is the wrong size"
			end
			
			tileset = Tileset.new(tileset_bitmap, tile_size, margin, spacing)
			
			first_gid = tileset_data['firstgid']
			tilesets[first_gid] = tileset
		end
		
		first_gids = tilesets.keys.reverse
		
		# Load layers
		
		data['layers'].each do |layer_data|
			next unless layer_data['visible'] == true
			next unless layer_data['type'] == 'tilelayer'
			
			name = layer_data['name']
			layer_size = [layer_data['width'], layer_data['height']]
			# Offset is defined by map coords, not pixels
			offset = [layer_data['x'], layer_data['y']]
			
			gids = layer_data['data']
			gids.each_index do |i|
				gid = gids[i]
				next if gid == 0
				
				tile = Tile.new
				
				fid = first_gids.find {|fid| fid <= gid}
				id = gid - fid
				tileset = tilesets[fid]
				tile.bitmap = tileset[id]
				
				coords = i.divmod(layer_size.x).reverse
				coords.x += offset.x
				coords.y += offset.y
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
		# - Remove sprite (unless needed elsewhere)
		@tiles.each do |tile|
			position = [tile.coords.x * @tile_size.x - offset.x,
				tile.coords.y * @tile_size.y - offset.y]
			
			# TODO
			# Draw only if the bitmap is in the boundary
			
			tile.bitmap.blit(position)
		end
	end
	
	def check_event(event)
	end
	
	def advance_frame
	end
end
