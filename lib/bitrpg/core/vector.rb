
# Immutable pair of numbers
class Vector
	attr_reader :x # Number
	attr_reader :y # Number
	
	class << self
		alias_method :[], :new
	end
	
	def initialize(x=0, y=0)
		@x = x
		@y = y
	end
	
	def ==(other)
		@x == other.x and @y == other.y
	end
	
	def +(other)
		Vector[@x + other.x, @y + other.y]
	end
	
	def -(other)
		Vector[@x - other.x, @y - other.y]
	end
	
	def -@
		Vector[-@x, -@y]
	end
	
	# Multiplies self with a scalar or another Vector (element-wise)
	def *(other)
		case other
		when Vector
			Vector[@x * other.x, @y * other.y]
		else
			Vector[@x * other, @y * other]
		end
	end
	
	alias_method :mul, :*
	
	# Divides self by a scalar or another Vector (element-wise)
	def /(other)
		case other
		when Vector
			Vector[@x / other.x, @y / other.y]
		else
			Vector[@x / other, @y / other]
		end
	end
	
	alias_method :div, :/
	
	# Rounds the vector coordinates to the nearest integer
	def round
		Vector[@x.round, @y.round]
	end
	
	def inspect
		"Vector[#{@x}, #{@y}]"
	end
end


class Vector2
	class << self
		alias_method :[], :new
	end
end