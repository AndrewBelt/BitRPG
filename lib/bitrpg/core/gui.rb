# An object on the screen which receives events
class Element
	attr_accessor :position # Vector
	
	def initialize
		@position = Vector[0, 0]
	end
	
	# Must be called by the main thread for Mac OS X compatability
	def draw(renderer, rect)
	end
	
	# Returns whether the event was intercepted
	def handle_event(event)
		false
	end
	
	# Prepare element for rendering
	# Must be called by the main thread for Mac OS X compatability
	def step
	end
end


class Composite < Element
	def draw(renderer, rect)
		offset_rect = rect.shift(@position)
		
		# Draw the elements in reverse
		elements.reverse_each do |element|
			element.draw(renderer, offset_rect)
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
		raise "Cannot add Container to itself" if element == self
		@elements.unshift(element)
	end
	
	def remove(element)
		@elements.delete(element)
	end
end


class SpriteElement < Element
	def draw(renderer, rect)
		# Fail silently if texture does not exist
		if @sprite
			@sprite.draw(renderer, @position + rect.position)
		end
	end
end


class Font
	class << self
		attr_accessor :default # Font
	end
end


class Panel < Element
	attr_accessor :size # Vector
	attr_accessor :color # Color
	
	def initialize
		super()
		@color = Color::BLACK
	end
	
	def draw(renderer, rect)
		panel_rect = Rect.new(@position + rect.position, @size)
		renderer.draw_color = @color
		renderer.draw_rect(panel_rect)
	end
end


class Image < SpriteElement
	def initialize(filename)
		super()
		surface = Surface.load(filename)
		@sprite = Sprite.new(surface)
	end
end


class Label < SpriteElement
	attr_reader :text # String
	attr_reader :font # Font
	attr_reader :color # Color
	attr_reader :wrap_length # Integer
	
	def initialize
		super()
		@text = '.'
		@font = Font.default
		@color = Color.new
		@dirty = true
	end
	
	def text=(text)
		@text = text
		@dirty = true
	end
	
	def font=(font)
		@font = font
		@dirty = true
	end
	
	def color=(color)
		@color = color
		@dirty = true
	end
	
	def wrap_length=(wrap_length)
		@wrap_length = wrap_length
		@dirty = true
	end
	
	def step
		if @dirty
			surface = @font.render(@text, @color, @wrap_length)
			@sprite = Sprite.new(surface)
			@dirty = false
		end
	end
end
