@tool
extends DialogicPortrait
class_name DialogicPortraitAnim

## Default portrait scene.
## The parent class has a character and portrait variable.

@export_group('Settings')
@export_file var frameimg1 : String = ""
@export_file var frameimg2 : String = ""
@export_file var frameimg3 : String = ""
@export_file var frameimg4 : String = ""
@export_file var frameimg5 : String = ""
@export_file var frameimg6 : String = ""
@export_file var frameimg7 : String = ""
@export_file var frameimg8 : String = ""
@export_file var default : String = ""
@export var frames : int = 4
@export var speed : int = 1
@export_group("")

@onready var textrect : Node = %TextureRect
@onready var anim : AnimatedTexture = textrect.texture

func assign_textureanim():
	
	anim.set_frames(frames)
	anim.set_frame_texture(0,load(frameimg1))
	anim.set_frame_texture(1,load(frameimg2))
	anim.set_frame_texture(2,load(frameimg3))
	anim.set_frame_texture(3,load(frameimg4))
	anim.set_frame_texture(4,load(frameimg5))
	anim.set_frame_texture(5,load(frameimg6))
	anim.set_frame_texture(6,load(frameimg7))
	anim.set_frame_texture(7,load(frameimg8))
	
	return anim

## Load anything related to the given character and portrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	apply_character_and_portrait(passed_character, passed_portrait)
	apply_texture($TextureRect,default)

func _on_continued_revealing_text() -> void:
	anim.set_pause(true)

func _on_dialogic_node_dialog_text_finished_revealing_text() -> void:
	anim.set_pause(false)
