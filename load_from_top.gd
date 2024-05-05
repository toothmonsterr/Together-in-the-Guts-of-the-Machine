@tool
extends Container

@export_range(175,900) var startingY : int = 175
@export var tick_rate : float = 2.0 # seconds
@export var reveal_rate : int = 1
var sizeY := startingY
var sizeX := 1200
var finalY := 900
var t := 0

func draw_down (Y, T):
	while sizeY < Y:
		var timer = get_tree().create_timer(T).timeout
		await timer
		sizeY += reveal_rate
		set_size( Vector2(sizeX,sizeY) )
		continue

func _input(InputEventKey) -> void:
	reset_size()
	draw_down(finalY, tick_rate)
