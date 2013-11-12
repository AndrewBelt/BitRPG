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

# Initialize modules and classes
Game.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# TODO
# Figure out a better font management scheme
default_font = Font.new('fonts/visitor1.ttf', 10)
DialoguePanel.font = default_font

# Eager-load the singleton classes
MAP_SCREEN = MapScreen.instance
MAP = Map.instance

# The REPL thread
require './lib/core/irb'
repl_thread = Thread.new do
	sleep 0.1
	IRB.start_mini
	Game.quit
end

Game.run
repl_thread.kill if repl_thread.alive?
