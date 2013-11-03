# An object on the screen which receives events
class Element
	attr_accessor :position
	
	def initialize
		@position = Vector[0, 0]
	end
	
	def draw(offset)
	end
	
	# Returns whether the event was intercepted
	def handle_event(event)
		false
	end
	
	def advance_frame
	end
end


class Container < Element
	attr_accessor :elements
	
	def initialize
		super
		@elements = []
	end
	
	def draw(offset)
		@elements.each do |element|
			element.draw(@position + offset)
		end
	end
	
	def handle_event(event)
		@elements.each do |element|
			return true if element.handle_event(event)
		end
		
		false
	end
	
	def advance_frame
		@elements.each do |element|
			element.advance_frame
		end
	end
end


class Font
	class << self
		def new(*args)
			self.load(*args)
		end
		
		# def load(filename, size); end
	end
	
	# def blit(color, x, y, text); end
end


class Text < Element
	attr_accessor :text
	attr_accessor :font
	attr_accessor :color
	
	def initialize
		super
		@text = ''
		@color = Color.new
	end
	
	def draw(offset)
		@font.blit(@color, @position.x, @position.y, @text)
	end
end
