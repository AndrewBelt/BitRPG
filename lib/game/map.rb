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
		add @map
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
	
	attr_reader :player # Character
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
			
			tileset = Tileset.all[tileset_name]
			raise "Could not find tileset '#{tileset_name}'" unless tileset
			tilesets[first_gid] = tileset
		end
		
		# Reversed so we can find the greatest key less than or
		# equal to a given gid
		first_gids = tilesets.keys.reverse
		
		# Load layers
		
		layer = 0
		data['layers'].each do |layer_name, gids|
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
				tile.layer = layer
				position_y, position_x = index.divmod(@map_size.x)
				tile.position = Vector[position_x, position_y]
				@map_tiles << tile
			end
			
			layer += 1
		end
		
		@map_tiles.sort!
		
		# Set up camera crew
		@camera = Camera.new
	end
	
	def add(entity)
		@entities << entity
	end
	
	def remove(entity)
		@entities.delete(entity)
	end
	
	def collides?(position)
		# Check boundary collision
		return true unless (0...@map_size.x) === position.x and
			(0...@map_size.y) === position.y
		
		# Check tile collision (using special collision layer)
		index = position.x + @map_size.x * position.y
		return true if @collisions[index]
		
		# Check entity collision
		pick(position).each do |entity|
			return true if entity.collides?
		end
		
		false
	end
	
	# Returns the entities found at a map position
	def pick(position)
		@entities.select do |entity|
			entity.hit?(position)
		end
	end
	
	# Helper methods
	
	def player=(player)
		if player
			player.behavior = PlayerBehavior.new
		end
		
		@player = player
	end
	
	def follow(entity)
		@camera = FollowCamera.new(entity)
	end
	
	# Returns a sorted list of all Tiles, Entities, Characters, etc
	# for rendering
	def all_tiles
		@entities.sort!
		
		all_tiles = @map_tiles + @entities
		all_tiles.sort
	end
	
	def draw(offset)
		screen_size = Game.instance.size
		center = @camera.center + Vector[0.5, 0.5]
		camera_offset = @tile_size.mul(center) - screen_size / 2
		
		all_tiles.each do |tile|
			position = @tile_size.mul(tile.position) - camera_offset
			position = position.round
			
			tile.draw(position)
		end
	end
	
	def handle_event(event)
		if !Game.instance.script_running? and @player
			# Assume that the player's behavior is a PlayerBehavior
			return true if @player.behavior.handle_event(event)
		end
		
		case event.type
		when :key_down
			if event.key == :space
				try_action
			end
		end
		
		false
	end
	
	def step
		# Step the frames of the elements
		@entities.each do |entity|
			entity.step(self)
		end
	end
	
private
	
	def try_action
		if @player and !@player.walking?
			face_position = @player.face_position
			face_entity = pick(face_position).find {|e| e.action? }
			return unless face_entity
			
			Game.instance.run_script do
				face_entity.action
			end
		end
	end
end
