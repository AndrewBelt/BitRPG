
class Color
	attr_accessor :r
	attr_accessor :g
	attr_accessor :b
	attr_accessor :a
	
	class << self
		# Converts a hex string ("#ffffff" or just "ffffff") to a Color
		def from_hex(str)
			match = str.match(/#?(..)(..)(..)/)
			values = match[1, 3].map {|s| s.to_i(16)}
			Color.new(*values)
		end
	end
	
	def initialize(r=0, g=0, b=0, a=1)
		@r, @g, @b, @a = r, g, b, a
	end
	
	BLACK   = Color.new(0, 0, 0)
	WHITE   = Color.new(255, 255, 255)
	RED     = Color.new(255, 0, 0)
	GREEN   = Color.new(0, 255, 0)
	BLUE    = Color.new(0, 0, 255)
	CYAN    = Color.new(0, 255, 255)
	MAGENTA = Color.new(255, 0, 255)
	YELLOW  = Color.new(255, 255, 0)
end
