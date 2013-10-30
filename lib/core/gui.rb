
module Element
end


class Font
	class << self
		def new(*args)
			self.load(*args)
		end
		
		# def load(filename, size); end
	end
	
	# def blit(color, position, text); end
end


class Text
	
end