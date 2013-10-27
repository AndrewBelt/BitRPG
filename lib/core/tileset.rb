class Tileset
	include Enumerable
	
	attr_reader :bitmap
	attr_reader :tile_size
	attr_reader :margin
	attr_reader :spacing
	attr_reader :sheet_size
	
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
		
		@cached_bitmaps = {}
	end
	
	def [](id)
		y, x = id.divmod(@sheet_size.x)
		at([x, y])
	end
	
	def at(coords)
		cached_bitmap = @cached_bitmaps[coords]
		return cached_bitmap if cached_bitmap
		
		return nil unless (0...@sheet_size.x) === coords.x
		return nil unless (0...@sheet_size.y) === coords.y
		
		position = [@margin + (@tile_size.x + @spacing) * coords.x,
			@margin + (@tile_size.y + @spacing) * coords.y]
		
		clipped_bitmap = @bitmap.clip(position, @tile_size)
		@cached_bitmaps[coords] = clipped_bitmap
		clipped_bitmap
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