require './lib/util'
require './lib/game'
require './lib/map'
require './lib/entity'
require './lib/repl'

GAME = Game.load('./config.yml')

# The REPL thread
Thread.new do
	repl()
	GAME.quit
end.run

GAME.run
