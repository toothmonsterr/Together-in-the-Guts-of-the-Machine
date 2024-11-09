@tool
extends ColorRect

@export var on : bool = true
@export var AffectText : bool = true

@onready var layer := $".."

func showShader():
	if on:
		show()
	else:
		hide()

func _ready() -> void:
	showShader()

