@tool
extends ColorRect

@export var AffectText : bool = true
@export var darkness : float = 1.0 
@onready var labeltex := %LabelTex
@onready var texttex := %TextTex


func darken(val, subject):
	subject.modulate = Color.from_hsv(0,0,val,1)
	
func moveZ():
	if AffectText:
		set_z_index(1)
	else: 
		set_z_index(0)

func _process(_delta):
	moveZ()
	darken(darkness, labeltex)
	darken(darkness, texttex)
