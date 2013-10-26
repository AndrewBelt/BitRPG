require './lib/draw_target'

class Bitmap
	include DrawTarget
	
	# Original file path if known
	attr_reader :path
	
	def self.find(filename)
		path = File.realpath(filename)
		
		# Does this bitmap exist in the ObjectSpace?
		bitmap = ObjectSpace.each_object(self) do |bitmap|
			break bitmap if bitmap.path == path
		end
		
		# Load the bitmap if not
		unless bitmap
			bitmap = self.load
			bitmap.path
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
	# def blit(position, zoom); end
	
	# Creates a new bitmap and copies a rectangular portion of self's bitmap
	# def clip(position, size); end
end