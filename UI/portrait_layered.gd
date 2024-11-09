@tool
extends DialogicPortrait

## Default portrait scene.
## The parent class has a character and portrait variable.

@export_group('Main')

@onready var anim = $TextureRect
@onready var text = get_node("DialogicNode_DialogText")

func _on_continued_revealing_text():
	

## Load anything related to the given character and portrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	apply_character_and_portrait(passed_character, passed_portrait)
	apply_texture()
