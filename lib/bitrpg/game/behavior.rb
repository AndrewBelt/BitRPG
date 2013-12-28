class Behavior
	def next_direction
	end
end


class PlayerBehavior < Behavior
	def initialize
		@held_keys = []
	end
	
	def next_direction
		if !@next_direction
			# Purge the list of held keys
			@held_keys.select! {|key| Keyboard.held?(key)}
			
			@next_direction = @held_keys.last
		end
		
		
		@last_direction = @next_direction
		@next_direction = nil
		@last_direction unless Game.script_running?
	end
	
	def handle_event(event)
		case event.type
		when :key_down
			if !event.repeat and DIRECTIONS.include?(event.key)
				@next_direction = event.key
				@held_keys.delete(event.key)
				@held_keys << event.key
				return true
			end
		end
		
		false
	end
end
