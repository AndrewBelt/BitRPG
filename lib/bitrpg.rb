# raise 'erra'

begin
	require './lib/game'
	require './lib/draw_target'
	require './lib/sprite'
	require './lib/events'
rescue Exception => e
	puts e
	puts e.backtrace
end
