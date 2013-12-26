class Behavior
	def next_direction
	end
end


class PlayerBehavior < Behavior
	def next_direction
		@last_direction = @next_direction
		@last_direction = nil unless Keyboard.held?(@last_direction)
		@last_direction
	end
	
	def handle_event(event)
		case event.type
		when :key_down
			if DIRECTIONS.include?(event.key)
				@next_direction = event.key
				return true
			end
		end
		
		false
	end
end
