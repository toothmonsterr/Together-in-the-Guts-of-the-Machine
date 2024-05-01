extends DialogicGameHandler


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layout := Dialogic.start("my_timeline")
	layout.get_parent().remove_child(layout)
	$"..".add_child(layout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
