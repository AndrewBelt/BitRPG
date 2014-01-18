require 'singleton'
require 'bitrpg/game/state'
require 'bitrpg/game/tileset'
require 'bitrpg/game/entity'
require 'bitrpg/game/camera'


class Map < Element
	include Singleton
	
	# The number of map tiles composing the map
	attr_reader :map_size # Vector
	
	# The pixel dimensions of each tile
	attr_reader :tile_size # Vector
	
	attr_reader :map_tiles # [Tile]
	attr_reader :entities # [Tile]
	
	attr_accessor :player # Character
	attr_accessor :camera # Camera
	
	def initialize
		super
		clear
	end
	
	def clear
		@map_tiles = []
		@entities = []
		@collisions = []
	end
	
	def load(name)
		# TODO
		# If no extension is given, scan for yaml first, then TMX
		
		path = File.realpath(name)
		# load_yaml(path)
		load_tmx(path)
	end
	
	def load_yaml(path)
		require 'yaml'
		
		data = YAML.load_file(path)
		load_hash(data)
	end
	
	def load_tmx(path)
		require 'rexml/document'
		require 'base64'
		require 'zlib'
		
		source = File.read(path)
		document = REXML::Document.new(source)
		
		map_hash = {}
		
		document.elements.each('/map') do |map_el|
			orientation = map_el.attributes['orientation']
			raise "Map must be orthogonal" unless orientation == 'orthogonal'
			
			map_width = map_el.attributes['width'].to_i
			map_height = map_el.attributes['height'].to_i
			map_hash['map_size'] = [map_width, map_height]
			
			tile_width = map_el.attributes['tilewidth'].to_i
			tile_height = map_el.attributes['tileheight'].to_i
			map_hash['tile_size'] = [tile_width, tile_height]
			
			layers_hash = {}
			map_el.elements.each('layer') do |layer_el|
				name = layer_el.attributes['name']
				width = layer_el.attributes['width'].to_i
				height = layer_el.attributes['height'].to_i
				
				layer_el.elements.each('data') do |data_el|
					data_text = data_el.text.strip
					
					if data_el.attributes['encoding'] == 'base64'
						data_text = Base64.decode64(data_text)
					end
					
					if data_el.attributes['compression'] == 'zlib'
						data_text = Zlib::Inflate.inflate(data_text)
					end
					
					data_a = data_text.unpack('L<*')
					layers_hash[name] = data_a
					break
				end
			end
			map_hash['layers'] = layers_hash
			
			tilesets_hash = {}
			map_el.elements.each('tileset') do |tileset_el|
				name = tileset_el.attributes['name']
				firstgid = tileset_el.attributes['firstgid'].to_i
				tilesets_hash[firstgid] = name
			end
			map_hash['tilesets'] = tilesets_hash
			
			# Support only one /map element
			break
		end
		
		load_hash(map_hash)
	end
	
	def load_hash(data)
		clear
		
		@map_size = Vector[*data.fetch('map_size')]
		@tile_size = Vector[*data.fetch('tile_size')]
		
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
		return true unless Rect.new(Vector[0, 0], @map_size).include?(position)
		
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
	
	def follow(entity)
		@camera = FollowCamera.new(entity)
	end
	
	# Returns a sorted list of all Tiles, Entities, Characters, etc
	# for rendering
	def all_tiles
		@entities.sort!
		
		all_tiles = @map_tiles + @entities
		all_tiles
	end
	
	def draw(renderer, position)
		# Set up camera viewport
		camera_offset = (@tile_size * @camera.center -
			(@rect.size - @tile_size) / 2).round
		camera_rect = Rect.new(camera_offset, @rect.size)
		
		boundary_rect = Rect.new(Vector[0, 0], @tile_size * @map_size)
		camera_rect = camera_rect.constrain(boundary_rect)
		
		# TODO
		# Most of the CPU is spent in this loop
		# Either implement some of this in C or find a way around this.
		
		all_tiles.each do |tile|
			tile_rect = Rect.new((@tile_size * tile.position).round,
				tile.sprite.clip_rect.size)
			
			# Don't draw entity if not in the bounding box of the screen
			next unless camera_rect.overlaps?(tile_rect)
			
			tile.draw(renderer, tile_rect.position - camera_rect.position)
		end
	end
	
	def handle_event(event)
		# Disable controls if the script thread is active
		return false if Game.script_running?
		
		case event.type
		when :key_down
			if event.key == :space
				try_action
			end
		end
		
		false
	end
	
	def step
		# Step the player
		if @player and !Game.script_running?
			held = Keyboard.held
			direction = Vector[0, 0]
			direction += Vector[1, 0] if held.include?(:right)
			direction += Vector[-1, 0] if held.include?(:left)
			direction += Vector[0, 1] if held.include?(:down)
			direction += Vector[0, -1] if held.include?(:up)
			@player.walk(direction) if direction != Vector[0, 0]
		end
		
		# Step the frames of the elements
		@entities.each do |entity|
			entity.step
		end
	end
	
private
	
	def try_action
		if @player
			face_position = @player.face_position
			face_entity = pick(face_position).find {|e| e.action? }
			return unless face_entity
			
			Game.run_script do
				face_entity.action
			end
		end
	end
end
