require './lib/core/util'
require './lib/core/repl'
require './lib/game/game'
require './lib/game/map'
require './lib/game/entity'
require './lib/game/camera'

GAME = Game.load('./config.yml')

# The REPL thread
Thread.new do
	repl()
	GAME.quit
end.run

GAME.run
