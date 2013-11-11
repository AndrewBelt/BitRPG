require 'yaml'
require 'singleton'
require 'core/gui'
require 'game/state'
require 'game/tileset'
require 'game/entity'
require 'game/camera'
require 'game/hud'


class MapScreen < Container
	include Singleton
	
	attr_accessor :map # Map
	attr_accessor :dialogue_panel # DialoguePanel
	
	def initialize
		super
		
		@map = Map.instance
		@elements << @map
		
		# TODO
		# Hardcoded
		font = Font.new('fonts/visitor1.ttf', 10)
		@dialogue_panel = DialoguePanel.new(font)
		@dialogue_panel.position = Vector[10, 130]
		
		@saying = false
		@say_mutex = Mutex.new
		@say_resource = ConditionVariable.new
	end
	
	def say(text)
		@dialogue_panel.text = text
		@elements << @dialogue_panel
		@saying = true
		
		@say_mutex.synchronize do
			@say_resource.wait(@say_mutex)
		end
		
		@elements.delete(@dialogue_panel)
	end
end


class Map < Element
	include Singleton
	
	# The number of map tiles composing the map
	attr_reader :map_size # Vector
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # Vector
	
	attr_reader :map_tiles # [Tile]
	attr_reader :entities # [Tile]
	
	attr_accessor :player # Player
	
	# TODO
	# Remove this in favor of @player
	attr_accessor :player_behavior # PlayerBehavior
	attr_accessor :camera # Camera
	
	attr_accessor :background_color # Color
	
	def initialize
		super
		clear
	end
	
	def clear
		@map_tiles = []
		@entities = []
		@collisions = []
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
		collision_gid = nil
		
		data['tilesets'].each do |first_gid, tileset_name|
			# The first tile of the tileset named 'collision'
			# is the magic collision tile.
			# It  can be placed on any layer, and it won't be rendered.
			if tileset_name.downcase == 'collision'
				collision_gid = first_gid
				next
			end
			
			tilesets[first_gid] = Tileset.all[tileset_name]
		end
		
		# Reversed so we can find the greatest key less than or
		# equal to a given gid
		first_gids = tilesets.keys.reverse
		
		# Load layers
		
		data['layers'].each do |layer, gids|
			# Tile layer
			gids.each_index do |index|
				gid = gids[index]
				
				# gid of 0 means a blank space
				next if gid == 0
				
				if gid == collision_gid
					@collisions[index] = true
					next
				end
				
				# Get the sprite corresponding to the gid
				fid = first_gids.find {|fid| fid <= gid}
				id = gid - fid
				tileset = tilesets[fid]
				sprite = tileset[id]
				
				# Create and add the tile
				tile = Tile.new(sprite)
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
	
	def collides?(position)
		return true unless (0...@map_size.x) === position.x and
			(0...@map_size.y) === position.y
		
		index = position.x + @map_size.x * position.y
		return true if @collisions[index]
		
		@entities.each do |entity|
			if entity.hit?(position)
				return true if entity.collides?
			end
		end
		
		false
	end
	
	# Returns a sorted list of all Tiles, Entities, Characters, etc
	# for rendering
	def all_tiles
		# TODO
		# Sort by z-order
		
		@map_tiles + @entities
	end
	
	def draw(offset)
		screen_size = Game.size
		center = @camera.center + Vector[0.5, 0.5]
		camera_offset = @tile_size.mul(center) - screen_size / 2
		
		# TODO
		# Combine static tile rendering with entities
		all_tiles.each do |tile|
			position = @tile_size.mul(tile.position) - camera_offset
			position = position.round
			
			# TODO
			# Draw only if the bitmap is in the boundary
			
			tile.draw(position)
		end
	end
	
	def handle_event(event)
		if @player_behavior
			return true if @player_behavior.handle_event(event)
		end
		
		false
	end
	
	def step
		# Step the frames of the elements
		@entities.each do |entity|
			entity.step(self)
		end
	end
end
