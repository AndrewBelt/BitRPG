require 'core/gui'
require 'game/character.rb'

class DialoguePanel < Container
	class << self
		attr_accessor :font
	end
	
	def initialize(name, text)
		super()
		
		# TODO
		# Add customization or at least remove the hardcoded stuff
		
		rectangle = Rectangle.new
		rectangle.color = Color::WHITE
		rectangle.size = Vector[220, 40]
		add rectangle
		
		label = Label.new
		label.font = DialoguePanel.font
		label.color = Color::BLACK
		label.text = "#{name}: #{text}"
		label.position = Vector[8, 6]
		add label
		
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
		MapScreen.instance.add(dialogue_panel)
		dialogue_panel.wait
		MapScreen.instance.elements.delete(dialogue_panel)
	end
end