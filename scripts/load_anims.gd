@tool
extends AnimationPlayer
@export_node_path var backgroundNode : NodePath = ""
@export_node_path var UINode : NodePath = ""
@export_node_path var spriteNode : NodePath = ""

@export_group("Scene Start")
@export var backgroundAnimation : String = "load_background"
@export var UIAnimation : String = "load_in_UI"
@export var spriteAnimation : String = "load_in_sprite"

func scene_start():
	set_autoplay(backgroundAnimation)
	animation_set_next(backgroundAnimation,spriteAnimation)
	animation_set_next(spriteAnimation, UIAnimation)

func _init() -> void:
	scene_start()
