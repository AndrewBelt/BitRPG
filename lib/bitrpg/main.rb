# TODO
# Should be done by the C launcher
# Add these relative directories to the library path
$: << '../lib'
$: << '../ext'

require 'bitrpg'


logo = %q{ ___ _ _   ___ ___  ___ 
| _ |_) |_| _ \ _ \/ __|
| _ \ |  _|   /  _/ (_ |
|___/_|\__|_|_\_|  \___|

}
puts logo

# Eager-load the singleton classes
GAME = Game.instance
MAP = Map.instance

MAP_SCREEN = Container.new
MAP_SCREEN.add(MAP)

# Initialize modules and classes
GAME.from_yaml('./config.yml')
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
	GAME.quit
end

# require 'ruby-prof'
# RubyProf.start

GAME.run
repl_thread.kill if repl_thread.alive?

# result = RubyProf.stop
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('prof.txt', 'w'), {})
