
class FramerateMeter < Container
	attr_accessor :delay # Integer
	
	def initialize
		super()
		@delay = 1
		@frame = 0
		
		@label = Label.new
		
		# TODO
		# This shouldn't be hard coded
		@label.color = Color::WHITE
		@elements << @label
	end
	
	def step
		if @frame == 0
			last_framerate = Game.last_framerate
			if last_framerate
				@label.text = "%.2f fps" % last_framerate
			end
		end
		
		@frame += 1
		@frame %= @delay
	end
end


class TextBox < Container
	def initialize
		super()
		
		@label = Label.new
		@label.color = Color::WHITE
		@label.update
		add(@label)
	end
	
	def handle_event(event)
		case event.type
		when :text
			@label.text << event.text
			@label.update
			return true
		when :key_down
			if event.key == :backspace
				@label.text.chop!
				@label.update
				return true
			end
		end
		
		false
	end
end