require './lib/core/util'
require './lib/game/game'
require './lib/game/tileset'
require './lib/game/map'
require './lib/game/entity'
require './lib/game/camera'

logo = %q{ ___ _ _   ___ ___  ___ 
| _ |_) |_| _ \ _ \/ __|
| _ \ |  _|   /  _/ (_ |
|___/_|\__|_|_\_|  \___|

}

# Initialize modules and classes
Game.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# Create the global objects
MAP = Map.new

# The REPL thread
require './lib/core/irb'
Thread.new do
	puts logo
	IRB.start_mini
	Game.quit
end

Game.run
