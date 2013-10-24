class Tilesheet
	include Enumerable
	
	def initialize(bitmap, tile_size, margin=0, spacing=0)
		@bitmap = bitmap
		@tile_size = tile_size
		@margin = margin
		@spacing = spacing
		
		size = @bitmap.size
		@sheet_size = [(size.x - 2 * margin + spacing) / (spacing + @tile_size.x),
			(size.y - 2 * margin + spacing) / (spacing + @tile_size.y)]
		
		# TODO
		# Check validity of @sheet_size
	end
	
	def [](id)
		y, x = id.divmod(@sheet_size.x)
		return nil if y >= @sheet_size.y
		
		position = [@margin + (@tile_size.x + @spacing) * x,
			@margin + (@tile_size.y + @spacing) * y]
		
		# TODO
		# Generate a Sprite with [position, @tile_size]
	end
	
	def length
		@sheet_size.x * @sheet_size.y
	end
	
	def each
		length.times do |id|
			yield self[id]
		end
	end
end