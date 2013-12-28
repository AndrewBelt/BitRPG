
class Window
	attr_reader :renderer
end


class Renderer
	alias_method :flip, :present
end


class Texture
end


class Surface
	class << self
		# def load(filename); end
	end
end


# A rectangular portion of a Surface, and a lazy Texture
class Sprite
	attr_reader :surface # Surface
	attr_accessor :clip_rect # Rect
	
	attr_reader :texture # Texture
	
	# The sprite represents the entire Surface by default
	def initialize(surface)
		@surface = surface
		@clip_rect = Rect.new(Vector[0, 0], surface.size)
	end
	
	def draw(renderer, position=Vector.new)
		# Lazy create the Texture
		if @surface
			@texture = Texture.new(renderer, @surface, @clip_rect)
			@surface = nil
		end
		
		renderer.copy(@texture, position)
	end
	
	def size
		@clip_rect.size
	end
end
