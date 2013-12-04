class Surface
	# def blit(source_surface, source_rect=Rect.new,
	# 	dest_position=Vector[0, 0], zoom=1); end
	
	# Wraps #draw_to of the source object
	def draw(source, rect=nil)
		unless rect
			rect = Rect.new(Vector[0, 0], size)
		end
		
		source.draw_to(self, rect)
	end
end