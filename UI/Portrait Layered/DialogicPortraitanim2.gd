@tool
extends DialogicPortrait

@export_group('Settings')
@export_file var default : String = ""
@export_file var frame1 : String = ""
@export_file var frame2 : String = ""
@export_file var frame3 : String = ""
@export_file var frame4 : String = ""
@export_file var frame5 : String = ""
@export_file var frame6 : String = ""
@export_file var frame7 : String = ""
@export_file var frame8 : String = ""
@export var frames : int = 4
@export var speed : int = 1

@onready var anim : Node = %AnimatedSprite2D
@onready var sprites := SpriteFrames.new()
@onready var spritepath : String = sprites.resource_path

var portraitanim := "PortraitAnim"

func _ready() -> void:
	anim.set_sprite_frames(sprites)
	sprites.add_animation(&"")
	sprites.add_frame(&"", load(frame1))
	sprites.add_frame(&"", load(frame2))
	sprites.add_frame(&"", load(frame3))
	sprites.add_frame(&"", load(frame4))
	if frame5 != "":
		sprites.add_frame(&"", load(frame5))
		if frame6 != "":
			sprites.add_frame(&"", load(frame6))
			if frame7 != "":
				sprites.add_frame(&"", load(frame7))
				if frame8 != "":
					sprites.add_frame(&"", load(frame8))

## Load anything related to the given character and portrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void: 
	apply_character_and_portrait(passed_character, passed_portrait)
	apply_texture(%AnimatedSprite2D, spritepath)
