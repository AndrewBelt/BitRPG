require './lib/util'
require './lib/game'
require './lib/map'

GAME = Game.load('./config.yml')
GAME.run
