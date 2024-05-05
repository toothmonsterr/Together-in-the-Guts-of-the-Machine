@tool
extends AnimationPlayer
var UI : String = "load_in_UI"
var sprite : String = "load_in_sprite"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_autoplay(sprite)
	animation_set_next (sprite,UI)
