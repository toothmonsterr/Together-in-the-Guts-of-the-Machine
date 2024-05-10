extends CanvasLayer

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %Label
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var dialogue_sprites : Node = %Sprites
@onready var dialogue_background : Control = %Background
@onready var background_2D : AnimatedSprite2D = %Background2D

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			queue_free()
			return

		# If the node isn't ready yet then none of the labels will be ready yet either
		if not is_node_ready():
			await ready

		dialogue_line = next_dialogue_line
		
		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = tr(dialogue_line.character, "dialogue")
		
		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Show our balloon
		balloon.show()
		will_hide_balloon = false


		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Wait for input
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states =  [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)

### Mutations


func set_background(background_name: String, load_in:bool) -> void:
	
	var sf := background_2D.get_sprite_frames()
	var anims := sf.get_animation_names()
	var frames : int = sf.get_frame_count(background_name)
	if load_in:
		if anims.has(background_name):
			background_2D.animation = background_name
			background_2D.set_frame_and_progress(0,true)
		else:
			background_2D.stop()
	else:
		background_2D.animation = background_name
		background_2D.set_frame_and_progress(frames,false)

func add_portrait(character: String, load: bool) -> void:
	# Instantiate the character
	var _c : CharacterResource = Manager.characters.get(character)
	var portrait = load(_c.node_path).instantiate()
	dialogue_sprites.add_child(portrait)

	if load:
		#var shader = dialogue_sprites.material
		#var shader_posY = shader.get_shader_param("Position Y")
		#print(shader)
		#print(shader_posY)
		## Character loads in
		#var _l := 1.5
		#shader.set_shader_parameter(shader_posY, _l)
		pass


#func call_portrait(character: String, method: String) -> void:
	#portraits[character].call(method)
#
#
#func remove_portrait(character: String) -> void:
	#var portrait = portraits[character]
#
	## Character leaves
	#var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(portrait, "position:y", 1000.0, 0.5).from(0.0)
	#await get_tree().create_timer(0.8).timeout
	#portraits.erase(character)
	#portrait.queue_free()

### Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	pass # Replace with function body.
