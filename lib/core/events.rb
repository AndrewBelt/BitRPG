class EventQueue
	include Enumerable
	
	# def self.new; end
	# def each; end
	# def register_display(display); end
	# def register_keyboard; end
end


class Event
	attr_reader :type
	attr_reader :key
	attr_reader :chr
	attr_reader :repeat
	
	class << self
		attr_reader :event_types
	end
end


module Keyboard
	class << self
		attr_reader :key_codes
		
		# def held; end
	end
end