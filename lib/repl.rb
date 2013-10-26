
$prompt = '>> '

def rep
	print $prompt
	
	begin
		input = gets
		return false unless input
		puts eval(input)
	rescue => e
		puts e
		puts e.backtrace
	end
end

def repl
	loop do
		rep
	end
end