
class Event
	attr_reader :type
	
	# Key events
	attr_reader :repeat
	attr_reader :key
	attr_reader :text
end


module Keyboard
	class << self
		# def update_held; end
		attr_reader :held
		
		def held?(key)
			held.include?(key)
		end
	end
end
