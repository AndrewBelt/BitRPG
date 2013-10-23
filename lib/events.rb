class Event
	attr_reader :type
	attr_reader :keycode
	attr_reader :keychar
	attr_reader :repeat
	
	def ifclose
		yield if @type == :close
	end
	
	def ifkeycode
		yield(@keycode) if @type == :keycode
	end
	
	def ifkeychar
		if @type == :keychar
			yield(@keychar, @keycode, @repeat)
		end
	end
end