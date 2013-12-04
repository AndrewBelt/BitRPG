
class FramerateMeter < Container
	attr_accessor :delay # Integer
	
	def initialize()
		super()
		@delay = 1
		@frame = 0
		
		@label = Label.new
		@label.font = Font.default
		
		# TODO
		# This shouldn't be hard coded
		@label.color = Color::WHITE
		@elements << @label
	end
	
	def step
		if @frame == 0
			last_framerate = Game.instance.last_framerate
			if last_framerate
				@label.text = "%.2f fps" % last_framerate
			end
		end
		
		@frame += 1
		@frame %= @delay
	end
end
