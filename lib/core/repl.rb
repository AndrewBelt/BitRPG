
$prompt = '>> '

def repl
	loop do
		print $prompt
		
		begin
			input = gets
			break unless input
			result = eval(input)
			p result if result
		rescue => e
			puts e
			puts e.backtrace
		end
	end
end