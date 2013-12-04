require 'irb'

module IRB
	def self.start_mini
		unless @__initialized
			IRB.setup(nil)
			@__initialized = true
		end
			
		@CONF[:PROMPT][:MINI] = {
			:PROMPT_I => ">> ",
			:PROMPT_N => "*> ",
			:PROMPT_S => "   ",
			:PROMPT_C => "?> ",
			:RETURN => "=> %s\n"
		}
		@CONF[:PROMPT_MODE] = :MINI
		
		irb = Irb.new
		
		@CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
		@CONF[:MAIN_CONTEXT] = irb.context
		catch(:IRB_EXIT) do
			irb.eval_input
		end
	end
end