
module Element
end


class Font
	class << self
		def new(*args)
			self.load(*args)
		end
		
		# def load(filename, size); end
	end
	
	# def blit(color, x, y, text); end
end


class Text
end
