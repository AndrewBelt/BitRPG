
class Window
	attr_reader :surface
	
	def size
		surface.size
	end
	
	alias_method :flip, :update
end
