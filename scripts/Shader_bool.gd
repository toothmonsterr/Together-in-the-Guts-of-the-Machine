@tool
extends ColorRect

@export var on : bool = true
@export var AffectText : bool = true

func moveZ():
	if AffectText:
		set_z_index(1)
	else: 
		set_z_index(0)

func showShader():
	if on:
		show()
	else:
		hide()

func _ready() -> void:
	moveZ()
	showShader()

