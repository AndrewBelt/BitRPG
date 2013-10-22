begin
	require './lib/game'
	require './lib/draw_target'
	require './lib/sprite'
rescue Exception => e
	puts e
	puts e.backtrace
end
