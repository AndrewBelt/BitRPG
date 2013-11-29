class Vector
	attr_accessor :x
	attr_accessor :y
	
	class << self
		# deprecated
		def [](x=0, y=0)
			Vector.new(x, y)
		end
	end
	
	def initialize(x=0, y=0)
		@x = x
		@y = y
	end
	
	def +(other)
		Vector.new(@x + other.x, @y + other.y)
	end
	
	def -(other)
		Vector.new(@x - other.x, @y - other.y)
	end
	
	# Multiplies self with a scalar or another Vector (element-wise)
	def *(other)
		case other
		when Vector
			Vector.new(@x * other.x, @y * other.y)
		else
			Vector.new(@x * other, @y * other)
		end
	end
	
	# Divides self by a scalar or another Vector (element-wise)
	def /(other)
		case other
		when Vector
			Vector.new(@x / other.x, @y / other.y)
		else
			Vector.new(@x / other, @y / other)
		end
	end
	
	def round
		Vector.new(@x.round, @y.round)
	end
	
	def inspect
		"Vector[#{@x}, #{@y}]"
	end
end

p Vector.new