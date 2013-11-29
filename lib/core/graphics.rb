require 'matrix'
require 'core/util'


class Bitmap
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
	
	# Converts a hex string ("#ffffff" or just "ffffff") to a Color
	def self.from_hex(str)
		match = str.match(/#?(..)(..)(..)/)
		values = match[1, 3].map {|s| s.to_i(16)}
		Color.new(*values)
	end
	
	def initialize(r=0, g=0, b=0, a=1)
		@r, @g, @b, @a = r, g, b, a
	end
	
	BLACK = Color.new(0, 0, 0)
	WHITE = Color.new(1, 1, 1)
	RED   = Color.new(1, 0, 0)
	GREEN = Color.new(0, 1, 0)
	BLUE  = Color.new(0, 0, 1)
end
