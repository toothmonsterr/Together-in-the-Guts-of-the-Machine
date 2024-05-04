@tool
extends ColorRect

@export var AffectText : bool = true

func moveZ():
	if AffectText:
		set_z_index(1)
	else: 
		set_z_index(0)

func _process(delta):
	moveZ()
