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
	
	def step
	end
end


class Composite < Element
	def draw(offset)
		elements.each do |element|
			element.draw(@position + offset)
		end
	end
	
	def handle_event(event)
		elements.each do |element|
			return true if element.handle_event(event)
		end
		
		false
	end
	
	def step
		elements.each do |element|
			element.step
		end
	end
	
	# Subclasses will likely override this
	def elements
		[]
	end
end


class Container < Composite
	attr_accessor :elements
	
	def initialize
		super
		@elements = []
	end
end


class Font
	class << self
		attr_accessor :default # Font
		
		def new(*args)
			self.load(*args)
		end
		
		# Loads a TTF font with the given font size
		# To change the font size, you must load multiple fonts
		# def load(filename, size); end
	end
	
	# def blit(color, x, y, text); end
end


class Label < Element
	attr_accessor :text
	attr_accessor :font
	attr_accessor :color
	
	def initialize
		super
		@text = ''
		@color = Color.new
	end
	
	def draw(offset)
		position = @position + offset
		@font.blit(@color, position.x, position.y, @text)
	end
end


class Rectangle < Element
	attr_accessor :size
	attr_accessor :color
	
	# def draw(offset); end
end