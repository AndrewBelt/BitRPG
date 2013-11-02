require 'matrix'
require './lib/core/util'


# Thanks to SFML for the idea of reversing the direction
# of the target and the drawable.
module DrawTarget
	def draw(drawable, *args)
		drawable.draw_to(self, *args)
	end
	
	def activate; end
	def size; end
end


module Drawable
	def draw_to(target, *args); end
end


class Bitmap
	include DrawTarget
	
	# def self.new(size); end
	
	# Loads from a file while bypassing the cache
	# def self.load(filename); end
	
	# Enables the bitmap for further drawing
	# def activate; end
	
	# Clears the bitmap to black
	# def clear; end
	
	# Returns an array with [width, height]
	# def size; end
	
	# Draws the bitmap to the currently activated DrawTarget
	# def blit(sx, sy, sw, sh, x, y, zoom); end
end


class Color
	attr_accessor :r
	attr_accessor :g
	attr_accessor :b
	attr_accessor :a
	
	def initialize(r=0, g=0, b=0, a=1)
		@r, @g, @b, @a = r, g, b, a
	end
	
	BLACK = Color.new(0, 0, 0)
	WHITE = Color.new(1, 1, 1)
	RED   = Color.new(1, 0, 0)
	GREEN = Color.new(0, 1, 0)
	BLUE  = Color.new(0, 0, 1)
end
