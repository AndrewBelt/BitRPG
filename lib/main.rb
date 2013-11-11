require 'core/util'
require 'game/game'
require 'game/tileset'
require 'game/map'
require 'game/entity'
require 'game/camera'

logo = %q{ ___ _ _   ___ ___  ___ 
| _ |_) |_| _ \ _ \/ __|
| _ \ |  _|   /  _/ (_ |
|___/_|\__|_|_\_|  \___|

}
puts logo

# Initialize modules and classes
Game.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# Eager-load the singleton classes
MAP_SCREEN = MapScreen.instance
MAP = Map.instance

# The REPL thread
require './lib/core/irb'
repl_thread = Thread.new do
	IRB.start_mini
	Game.quit
end

Game.run
repl_thread.kill
