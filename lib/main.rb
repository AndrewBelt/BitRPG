require './lib/core/util'
require './lib/core/repl'
require './lib/game/tileset'
require './lib/game/game'
require './lib/game/map'
require './lib/game/entity'
require './lib/game/camera'

Game.from_yaml('./config.yml')
Tileset.from_yaml('./tilesets.yml')

# The REPL thread
# Thread.new do
# 	repl()
# 	Game.quit
# end.run

Game.run
