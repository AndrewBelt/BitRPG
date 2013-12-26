# TODO
# Should be done by the C launcher
# Add these relative directories to the library path
$: << '../lib'
$: << '../ext'

require 'bitrpg'


puts "bitrpg #{BITRPG_VERSION_STR}"

# Eager-load the singleton classes
MAP = Map.instance

MAP_SCREEN = Container.new
MAP_SCREEN.add(MAP)

# Initialize modules and classes
Game.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# TODO
# Figure out a better font management scheme
# Font.default = Font.new('fonts/visitor1.ttf', 10)

# The REPL thread
require 'bitrpg/core/irb'
repl_thread = Thread.new do
	# Pause for suspense
	sleep 0.1
	IRB.start_mini
	Game.quit
end

Game.run
repl_thread.kill if repl_thread.alive?
