class Surface
	# def blit(dest_surface, source_rect=Rect.new,
	# 	dest_position=Vector[0, 0], zoom=1); end
	
	# Wraps #draw_to of the source object
	def draw(source, position=Vector[0, 0])
		source.draw_to(self, position)
	end
end