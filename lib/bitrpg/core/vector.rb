
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
		# Ensure immutability
		freeze
	end
	
	def ==(other)
		@x == other.x and @y == other.y
	end
	
	def <=>(other)
		# We only care about the order in the y direction.
		# Vectors with higher y values are greater.
		@y <=> other.y
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
	
	def map
		Vector[yield(@x), yield(@y)]
	end
	
	# Rounds the vector coordinates to the nearest integer
	def round
		map(&:round)
	end
	
	def constrain(top_left, bottom_right)
		x = @x.constrain(top_left.x, bottom_right.x)
		y = @y.constrain(top_left.y, bottom_right.y)
		Vector[x, y]
	end
	
	def inspect
		"Vector[#{@x}, #{@y}]"
	end
end


class Numeric
	# Clips the numberic to the given limits
	def constrain(low, high)
		if self < low
			low
		elsif self > high
			high
		else
			self
		end
	end
end