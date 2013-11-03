require 'json'
require 'psych'


# Load the Tiled map editor JSON file

filename = ARGV[0]
path = File.realpath(filename)
file = File.open(path)
data = JSON.load(file)

# Convert the data

orientation = data['orientation']
if orientation != 'orthogonal'
	raise "Map orientation is #{orientation} (expected orthogonal)"
end

map_size = [data['width'], data['height']]
map_length = map_size[0] * map_size[1]
tile_size = [data['tilewidth'], data['tileheight']]

output_data = {
	'map_size' => map_size,
	'tile_size' => tile_size,
	'layers' => {},
	'tilesets' => {}
}

data['layers'].each do |layer|
	name = layer['name']
	gids = layer['data']
	
	if gids.length != map_length
		raise "Number of tiles of layer '#{name}' is #{gids.length} " +
			"(expected #{map_length})"
	end
	
	output_data['layers'][name] = gids
end

data['tilesets'].each do |tileset|
	first_gid = tileset['firstgid']
	name = tileset['name']
	
	output_data['tilesets'][first_gid] = name
end

# Generate the output file path

extname = File.extname(path)
basename = File.basename(path, extname)
dirname = File.dirname(path)
output_path = File.expand_path("#{basename}.yml", dirname)
output_file = File.open(output_path, 'w')

# Monkey patch Psych to customize the YAML output style
# Thanks to Mislav Marohnić for the direction.

class Psych::Visitors::YAMLTree
	def visit_Array(o)
		register(o, @emitter.start_sequence(nil, nil, true,
			Psych::Nodes::Sequence::FLOW))
		o.each { |c| accept c }
		@emitter.end_sequence
	end
end

# Dump the data

Psych.dump(output_data, output_file)

# Psych.dump(output_data, output_file, {
# 	:line_width => -1
# })

puts "Successfully generated '#{output_path}'"
