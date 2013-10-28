require './lib/core/draw_target'

class Bitmap
	include DrawTarget
	
	attr_reader :parent
	
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
	# def blit(source_position, source_size, position, zoom); end
	
	# Creates a bitmap which references a rectangular portion
	# of self
	# def sub(position, size); end
end


class Color
	attr_accessor :r
	attr_accessor :g
	attr_accessor :b
	attr_accessor :a
	
	def initialize(r=0, g=0, b=0, a=1)
		@r, @g, @b, @a = r, g, b, a
	end
end