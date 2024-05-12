extends CanvasLayer

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

@export_range(0.0,1.0) var talk_speed: float = 0.25

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %Label
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var dialogue_sprites : Node = %Sprites
@onready var dialogue_background : Control = %Background
@onready var background_2D : AnimatedSprite2D = %Background2D
@onready var text_stylebox : StyleBox = %TextTex.get("theme_override_styles/panel")
@onready var box_anim : AnimatedTexture = text_stylebox.get("texture")

## Signals
signal loading()
signal loaded()

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

var frame : float = 0.0

var tween : Tween

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

func play_anim_textbox() -> void:
	box_anim.set_current_frame(0)
	box_anim.set_pause(false)

func stop_anim_textbox() -> void:
	box_anim.set_current_frame(0)
	box_anim.set_pause(true)

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

func reset_offset(node: CanvasItem, show: bool = true):
	var offsetY : int
	if show:
		offsetY = 0
	else:
		offsetY = node.texture.get_size()[1]
	node.set_offset(Vector2(0,offsetY))

func load_anim(node: CanvasItem, load_speed: float = 1.0, startY: int = 0, endY: int = 0, destroy: bool = false) -> void:
	node.set_offset(Vector2(0,startY))
	tween = create_tween()
	tween.tween_property(node, "offset", Vector2(0,endY), load_speed)
	if destroy:
		tween.tween_callback(func():
			node.get_parent().queue_free()
			)
	tween.tween_callback(tween.kill)

func skip_load(node: CanvasItem, finalY: int = 0, destroy: bool = false) -> void:
	if tween:
		tween.kill()
	loaded.emit()
	node.set_offset(Vector2(0,finalY))
	if destroy:
		node.queue_free()

func add_portrait(character: String, load: bool = true, load_speed: float = 1.0) -> void:
	if tween:
		tween.kill()
	#Gets the character resource
	var _c : CharacterResource = Manager.characters.get(character)
	#Sets character resource has_portrait to true
	_c.has_portrait = true
	# Instantiate the character
	var portrait = load(_c.node_path).instantiate()
	#Gets the child mask node
	var mask : Sprite2D = portrait.get_node("Mask2D")
	#parent to correct place
	dialogue_sprites.add_child(portrait)
	#load animation
	if load:
		loading.emit()
		var sizeY = mask.texture.get_size()[1]
		load_anim(mask, load_speed, -sizeY, 0)
	else:
		reset_offset(mask)

##Gets portrait of currently speaking character
func get_portrait() -> AnimatedSprite2D:
	var _c : CharacterResource = dialogue_line.character_resource
	var portrait : AnimatedSprite2D
	if dialogue_line.character_resource.has_portrait:
		portrait = get_node("Balloon/Sprites/%s/Mask2D/Portrait2D" % _c.id)
	else:
		portrait = null
	return portrait

func get_mask(obj_name: String) -> Node:
	var mask : Node2D = get_tree().get_node("../%s/Mask2D" % obj_name)
	return mask

func change_expression(character: String, expression: String):
	var _c : CharacterResource = Manager.characters.get(character)
	if _c.has_portrait: 
		var portrait : AnimatedSprite2D = get_node("Balloon/Sprites/%s/Mask2D/Portrait2D" % _c.id)
		var _a = portrait.get_sprite_frames().get_animation_names()
		
		if _a.has(expression):
			portrait.set_animation(expression)
		else:
			portrait.set_animation("default")
		
	else:
		print("No portrait set")
		pass

func remove_portrait(character: String, unload:bool = true, load_speed: float = 1.0) -> void:
	if tween:
		tween.kill()
	var _c : CharacterResource = Manager.characters.get(character)
	_c.has_portrait = false
	var portrait : Control = dialogue_sprites.get_node(_c.id)
	var mask : Sprite2D = portrait.get_node("Mask2D")
	if unload:
		loading.emit()
		var sizeY = mask.texture.get_size()[1]
		load_anim(mask, load_speed, 0, sizeY, true)
	else:
		portrait.queue_free()

func remove_all_portraits() -> void:
	for character in Manager.characters:
		Manager.characters[character].has_portrait = false
	var portraits = dialogue_sprites.get_children()
	for node in portraits:
		node.queue_free()

func reset_portrait_anim() -> void:
	var portrait = get_portrait()
	portrait.set_frame(0)

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
	
	var _c = dialogue_line.character_resource
	##Checks if current character has a portrait instantiated
	if _c.has_portrait:
		var portrait : AnimatedSprite2D = get_portrait()
		var sf : SpriteFrames = portrait.get_sprite_frames()
		var current_anim := portrait.get_animation()
		var frames : int = sf.get_frame_count(current_anim)
		
		##Adds to frame count per talk speed
		if frame < frames:
			frame = frame + talk_speed
		else:
			frame = 0.0
		
		##Sets sprite_frame to current frame
		portrait.set_frame(frame)
	
	else:
		pass


func _on_dialogue_label_finished_typing() -> void:
	if dialogue_line.character_resource.has_portrait:
		reset_portrait_anim()
	else:
		pass


func _on_dialogue_label_skipped_typing() -> void:
	
	if dialogue_line.character_resource.has_portrait:
		if tween:
			tween.kill()
		var mask : Node2D = get_portrait().get_parent()
		skip_load(mask)
		reset_portrait_anim()
	else:
		pass

func _on_dialogue_label_paused_typing(duration: float) -> void:
	if dialogue_line.character_resource.has_portrait:
		reset_portrait_anim()
	else:
		pass
