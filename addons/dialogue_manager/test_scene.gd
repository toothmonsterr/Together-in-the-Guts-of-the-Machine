class_name BaseDialogueTestScene extends Node


const DialogueSettings = preload("./settings.gd")

@onready var title: String = DialogueSettings.get_user_value("run_title")
@onready var resource: DialogueResource = load(DialogueSettings.get_user_value("run_resource_path"))
@onready var container := %BalloonContainer

func _ready():

	# Normally you can just call DialogueManager directly but doing so before the plugin has been
	# enabled in settings will throw a compiler error here so I'm using get_singleton instead.
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	var balloon = dialogue_manager.show_dialogue_balloon(resource, title)
	balloon.reparent(container)

func _enter_tree() -> void:
	
	DialogueSettings.set_user_value("is_running_test_scene", false)


### Signals


func _on_dialogue_ended(_resource: DialogueResource):
	get_tree().quit()
