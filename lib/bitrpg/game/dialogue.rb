require 'bitrpg/core/gui'
require 'bitrpg/game/character'

class DialoguePanel < Container
	def initialize(name, text)
		super()
		
		# TODO
		# Add customization or at least remove the hardcoded stuff
		
		panel = Panel.new
		panel.color = Color::WHITE
		panel.size = Vector[220, 40]
		add(panel)
		
		label = Label.new
		label.color = Color::BLACK
		label.text = "#{name}: #{text}"
		label.wrap_length = panel.size.x
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
		dialogue_panel = DialoguePanel.new(@type.name, text)
		
		# TODO
		# Hard coded
		dialogue_panel.position = Vector[10, 130]
		
		MAP_SCREEN.add(dialogue_panel)
		dialogue_panel.wait
		MAP_SCREEN.remove(dialogue_panel)
	end
end
