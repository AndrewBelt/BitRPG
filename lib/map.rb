require './lib/state'
require './lib/tilesheet'
require 'json'

class Map < State
	# The number of map tiles composing the map
	attr_reader :map_size # [Integer, Integer]
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # [Integer, Integer]
	
	def initialize
		clear
	end
	
	def clear
		@tiles = []
		@entities = []
		@map_size = [0, 0]
		@tile_size = [0, 0]
	end
	
	def load(name)
		path = File.realpath("#{name}.json", 'maps')
		file = File.open(path)
		data = JSON.load(file)
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
			
			tileset_bitmap = Bitmap.load(image_filename)
			
			unless tileset_bitmap.size == image_size
				raise "Tileset '#{name}' is the wrong size"
			end
			
			tileset = TileSheet.new(tileset_bitmap, tile_size, margin, spacing)
			
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
			offset = [layer_data['x'], layer_data['y']]
			
			gids = layer_data['data']
			gids.each_index do |i|
				gid = gids[i]
				next if gid == 0
				
				fid = first_gids.find {|fid| fid <= gid}
				id = gid - fid
				tileset = tilesets[fid]
				tile_bitmap = tileset[id]
				
				map_pos = i.divmod(layer_size.x).reverse
				map_pos.x += offset.x
				map_pos.y += offset.y
				
				tile_sprite = Sprite.new(tile_bitmap)
				tile_sprite.position = [map_pos.x * @tile_size.x,
					map_pos.y * @tile_size.y]
				@tiles << tile_sprite
			end
		end
	end
	
	def add(entity, layer=1)
		@entities << entity
	end
	
	def draw_to(target)
		@tiles.each do |tile|
			target.draw(tile)
		end
		
		@entities.each do |entity|
			target.draw(entity, @tile_size)
		end
	end
	
	def check_event(event)
	end
	
	def advance_frame
	end
end
