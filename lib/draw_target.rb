
# Thanks to SFML for the idea of reversing the direction
# of the target and the drawable.
module DrawTarget
	def draw(drawable, *args)
		drawable.draw_to(self, *args)
	end
end
