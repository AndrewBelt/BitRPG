
class FramerateMeter < Container
	attr_accessor :delay # Integer
	
	def initialize(font)
		super()
		@delay = 1
		@frame = 0
		
		@label = Label.new
		@label.font = font
		
		# TODO
		# This shouldn't be hard coded
		@label.color = Color::WHITE
		@elements << @label
	end
	
	def step
		if @frame == 0
			last_framerate = Game.last_framerate
			@label.text = "%.2f fps" % last_framerate if last_framerate
		end
		
		@frame += 1
		@frame %= @delay
	end
end


class DialoguePanel < Container
	def initialize(font)
		super()
		
		@rectangle = Rectangle.new
		@rectangle.color = Color::WHITE
		@rectangle.size = Vector[220, 40]
		
		@label = Label.new
		@label.font = font
		@label.color = Color::BLACK
		@label.text = ''
		@label.position = Vector[10, 10]
		
		@elements << @rectangle
		@elements << @label
	end
	
	def text=(text)
		@label.text = text
	end
end