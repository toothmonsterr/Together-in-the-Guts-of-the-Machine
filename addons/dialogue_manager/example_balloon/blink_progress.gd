extends AnimatedSprite2D

@onready var label : DialogueLabel = %DialogueLabel

func _ready() -> void:
	if not label.is_typing:
		self.show()
		play("default")
	else:
		self.hide()

func _on_dialogue_label_finished_typing() -> void:
	if not label.is_typing:
		self.show()
		play("default")
	else:
		self.hide()
	
