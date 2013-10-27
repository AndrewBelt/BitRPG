require './lib/core/draw_target'

class Bitmap
	include DrawTarget
	
	# Original file path if known
	attr_accessor :path
	
	def self.find(filename)
		path = File.realpath(filename)
		
		# Does this bitmap exist in the ObjectSpace?
		bitmap = nil
		ObjectSpace.each_object(self) do |b|
			if b.path == path
				bitmap = b
				break
			end
		end
		
		# Load the bitmap if not
		unless bitmap
			bitmap = self.load(path)
			bitmap.path = path
		end
		
		bitmap
	end
	
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
	# def blit(position=[0, 0], zoom=1); end
	
	# Creates a new bitmap and copies a rectangular portion of self's bitmap
	# def clip(position, size); end
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