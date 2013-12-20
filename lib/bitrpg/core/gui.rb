# An object on the screen which receives events
class Element
	attr_accessor :position
	
	def initialize
		@position = Vector[0, 0]
	end
	
	def draw_to(dest, rect)
	end
	
	# Returns whether the event was intercepted
	def handle_event(event)
		false
	end
	
	def step
	end
end


class Composite < Element
	def draw_to(dest, rect)
		offset_rect = rect.shift(@position)
		
		# Draw the elements in reverse
		elements.reverse_each do |element|
			dest.draw(element, offset_rect)
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
	
	def add(element)
		@elements.unshift(element)
	end
	
	def remove(element)
		@elements.delete(element)
	end
end


class Font
	class << self
		attr_accessor :default
	end
end


class Label < Element
	attr_reader :text
	attr_accessor :font
	attr_accessor :color
	
	def initialize
		super
		@font = Font.default
		@color = Color.new
	end
	
	def draw_to(dest, rect)
		dest.blit(@surface, nil, @position, 1)
	end
	
	def text=(text)
		@surface = @font.render(text, @color)
		@text = text
	end
end


class Panel < Element
	attr_accessor :size
	attr_accessor :background_color
	
	# def draw(offset); end
end