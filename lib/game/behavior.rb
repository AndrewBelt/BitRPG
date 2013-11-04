class Behavior
	def next_direction
		nil
	end
end


class PlayerBehavior < Behavior
	def next_direction
		# Pressed keys have greater precedence than held keys.
		# In other words, keys that are pressed during the last
		# tile movement should be used rather than keys that are
		# currently being held.
		
		if !@next_direction
			held = Keyboard.held
			
			DIRECTIONS.each_key do |direction|
				if held.include?(direction)
					@next_direction = direction
					
					break if @last_direction == @next_direction
				end
			end
		end
		
		@last_direction, @next_direction = @next_direction, nil
		@last_direction
	end
	
	def handle_event(event)
		if event.type == :key_down
			if DIRECTIONS.include?(event.key)
				@next_direction = event.key
				return true
			end
		end
		
		false
	end
end
