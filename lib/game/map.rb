require './lib/core/gui'
require './lib/game/state'
require './lib/game/tileset'
require './lib/game/entity'
require './lib/game/behavior'
require './lib/game/camera'
require 'yaml'

class Map < Container
	# The number of map tiles composing the map
	attr_reader :map_size # Vector
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # Vector
	
	attr_reader :map_tiles # [Tile]
	attr_reader :entities # [Tile]
	
	attr_accessor :player # Character
	attr_accessor :camera # Camera
	
	attr_accessor :background_color # Color
	
	def initialize
		super
		clear
	end
	
	def clear
		@map_tiles = []
		@entities = []
		@background_color = Color.new
	end
	
	def load(name)
		path = File.realpath("#{name}.yml", 'maps')
		from_yaml(path)
	end
	
	def from_yaml(path)
		data = YAML.load_file(path)
		from_data(data)
	end
	
	def from_data(data)
		clear
		
		@map_size = Vector.elements(data.fetch('map_size'))
		@tile_size = Vector.elements(data.fetch('tile_size'))
		
		# Load tilesets
		
		tilesets = {} # {first_gid => Tileset}
		
		data['tilesets'].each do |first_gid, tileset_name|
			tilesets[first_gid] = Tileset.all[tileset_name]
		end
		
		first_gids = tilesets.keys.reverse
		
		# Load layers
		
		data['layers'].each do |layer, gids|
			# Collision layer
			if layer == 'collision'
				@collisions = gids.collect {|gid| gid != 0}
				next
			end
			
			# Tile layer
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
	
	def draw(offset)
		screen_size = Game.screen_size
		center = @camera.center
		camera_offset = @tile_size.mul(center + Vector[0.5, 0.5]) -
			screen_size / 2
		
		# TODO
		# Combine static tile rendering with entities
		all_tiles.each do |tile|
			position = @tile_size.mul(tile.position) - camera_offset
			
			# TODO
			# Draw only if the bitmap is in the boundary
			
			tile.sprite.draw(position)
		end
		
		# Draw the elements of this container last
		# e.g. HUD, pause menu, etc.
		super
	end
	
	def handle_event(event)
		handled = super
		return handled if handled
		
		if event.type == :key_down
			if [:up, :down, :left, :right].include?(event.key)
				@player.walk(event.key, false) if @player
				return true
			end
		end
		
		false
	end
	
	def advance_frame
		# Advance the frames of the elements
		super
		
		@entities.each do |entity|
			entity.advance_frame
		end
	end
end
