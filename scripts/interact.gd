extends Control

func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		var layout := Dialogic.start("timeline")
		var screenviewport := $"../2D"
		
		layout.get_parent()
		screenviewport.add_child(layout)
