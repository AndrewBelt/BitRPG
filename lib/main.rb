require 'core/util'
require 'game/game'
require 'game/tileset'
require 'game/map'
require 'game/entity'
require 'game/dialogue'

logo = %q{ ___ _ _   ___ ___  ___ 
| _ |_) |_| _ \ _ \/ __|
| _ \ |  _|   /  _/ (_ |
|___/_|\__|_|_\_|  \___|

}
puts logo

# Eager-load the singleton classes
GAME = Game.instance
MAP_SCREEN = MapScreen.instance
MAP = Map.instance

# Initialize modules and classes
GAME.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# TODO
# Figure out a better font management scheme
Font.default = Font.new('fonts/visitor1.ttf', 10)

# The REPL thread
require './lib/core/irb'
repl_thread = Thread.new do
	# Pause for suspense
	sleep 0.1
	IRB.start_mini
	GAME.quit
end

GAME.run
repl_thread.kill if repl_thread.alive?
