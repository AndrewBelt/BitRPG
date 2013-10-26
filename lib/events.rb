class EventQueue
	include Enumerable
	
	# def self.new; end
	# def each; end
	# def register_display(display); end
	# def register_keyboard; end
end

class Event
	attr_reader :type
	attr_reader :keycode
	attr_reader :chr
	attr_reader :repeat
end