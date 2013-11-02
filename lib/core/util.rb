require 'matrix'

class Vector
	def x
		self[0]
	end
	
	def y
		self[1]
	end
	
	def x=(x)
		self[0] = x
	end
	
	def y=(y)
		self[1] = y
	end
	
	# Element-wise multiplication
	def mul(other)
		self.map2(other, &:*)
	end
	
	# Element-wise multiplication
	def div(other)
		self.map2(other, &:/)
	end
end
