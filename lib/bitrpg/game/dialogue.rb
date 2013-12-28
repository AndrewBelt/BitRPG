require 'bitrpg/core/gui'
require 'bitrpg/game/character'

class DialoguePanel < Container
	INSET = 2
	
	def initialize(character_type, text, rect)
		super(rect)
		
		inside_rect = Rect.new(Vector[0, 0], @rect.size)
		
		box1 = Box.new(inside_rect)
		box1.color = Color::WHITE
		add(box1)
		
		box2 = Box.new(inside_rect.contract(Vector[4, 2]))
		box2.color = Color::BLACK
		add(box2)
		
		label = Label.new(inside_rect.contract(Vector[8, 4]))
		label.color = Color::WHITE
		label.text = "#{character_type.name}: #{text}"
		add(label)
		
		@mutex = Mutex.new
		@resource = ConditionVariable.new
	end
	
	def handle_event(event)
		if event.type == :key_down and event.key == :space
			broadcast
			return true
		end
		
		false
	end
	
	# Blocks until #broadcast is called
	def wait
		@mutex.synchronize do
			@resource.wait(@mutex)
		end
	end
	
	def broadcast
		@mutex.synchronize do
			@resource.broadcast
		end
	end
end


class Character
	def say(text)
		margin = 10
		height = 46
		
		dialogue_rect = Rect.new(
			Vector[margin, MAP_SCREEN.rect.size.y - margin - height],
			Vector[MAP_SCREEN.rect.size.x - 2 * margin, height])
		dialogue_panel = DialoguePanel.new(@type, text, dialogue_rect)
		
		MAP_SCREEN.add(dialogue_panel)
		dialogue_panel.wait
		MAP_SCREEN.remove(dialogue_panel)
	end
end
