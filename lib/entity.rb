class Entity
	def initialize
		@pos = [0, 0]
		@layer = 1
	end
	
	def place(pos)
		@pos = pos
	end
end