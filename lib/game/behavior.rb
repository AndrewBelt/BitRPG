class Behavior
	def next_direction
	end
end


class PlayerBehavior < Behavior
	def initialize
		@held_keys = []
	end
	
	def next_direction
		@last_direction = @next_direction || @held_keys.last
		@next_direction = nil
		@last_direction
	end
	
	def handle_event(event)
		case event.type
		when :key_down
			if DIRECTIONS.include?(event.key)
				@next_direction = event.key
				@held_keys << event.key
				return true
			end
			
		when :key_up
			if DIRECTIONS.include?(event.key)
				@held_keys.delete(event.key)
			end
		end
		
		false
	end
end
