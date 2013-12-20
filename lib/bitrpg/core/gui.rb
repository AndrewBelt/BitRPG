# An object on the screen which receives events
class Element
	attr_accessor :position # Vector
	
	def initialize
		@position = Vector[0, 0]
	end
	
	def draw_to(surface, rect)
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
	attr_accessor :elements # Array
	
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
		attr_accessor :default # Font
	end
end


class Label < Element
	attr_accessor :text # String
	attr_accessor :font # Font
	attr_accessor :color # Color
	attr_accessor :wrap_length # Integer
	
	def initialize
		super
		@font = Font.default
		@color = Color.new
		@wrap_length = 0
	end
	
	def draw_to(surface, rect)
		@surface.blit(surface, nil, rect.position + @position, 1)
	end
	
	def update
		@surface = @font.render(@text, @color, @wrap_length)
	end
end


class Panel < Element
	attr_accessor :size # Vector
	attr_accessor :color # Color
	
	def initialize
		super()
		@color = Color::BLACK
	end
	
	def draw_to(surface, rect)
		panel_rect = Rect.new(@position + rect.position, @size)
		surface.fill(panel_rect, @color)
	end
end