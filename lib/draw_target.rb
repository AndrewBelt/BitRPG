
# Thanks to SFML for the idea of reversing the direction
# of the target and the drawable.
module DrawTarget
	def draw(drawable)
		drawable.draw_to(self)
	end
end
