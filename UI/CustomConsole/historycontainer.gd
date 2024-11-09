extends DialogicLayoutLayer

@export_group('Look')
@export_subgroup('Font')
@export var font_use_global_size: bool = true
@export var font_custom_size: int = 15
@export var font_use_global_fonts: bool = true
@export_file('*.ttf') var font_custom_normal: String = ""
@export_file('*.ttf') var font_custom_bold: String = ""
@export_file('*.ttf') var font_custom_italics: String = ""

@export_subgroup('Buttons')
@export var show_open_button: bool = true
@export var show_close_button: bool = true

@export_group('Settings')
@export_subgroup('Events')
@export var show_all_choices: bool = true
@export var show_join_and_leave: bool = true

@export_subgroup('Behaviour')
@export var scroll_to_bottom: bool = true
@export var show_name_colors: bool = true
@export var name_delimeter: String = ": "

var scroll_to_bottom_flag: bool = false

@export_group('Private')
@export var HistoryItem: PackedScene = null

func get_text_box() -> RichTextLabel:
	return %ConsoleText

func get_history_box() -> ScrollContainer:
	return %MarginContainer

func get_history_log() -> VBoxContainer:
	return %VBoxContainer

var history_item_theme: Theme = null

func load_info(text:String, character:String = "", character_color: Color =Color(), icon:Texture= null) -> void:
	get_text_box().text = text
	
func show_history() -> void:
	for child: Node in get_history_log().get_children():
		child.queue_free()

	var history_subsystem: Node = DialogicUtil.autoload().get(&'History')
	for info: Dictionary in history_subsystem.call(&'get_simple_history'):
		var history_item : Node = HistoryItem.instantiate()
		history_item.set(&'theme', history_item_theme)
		match info.event_type:
			"Text":
				if info.has('character') and info['character']:
					if show_name_colors:
						history_item.call(&'load_info', info['text'], info['character']+name_delimeter, info['character_color'])
					else:
						history_item.call(&'load_info', info['text'], info['character']+name_delimeter)
				else:
					history_item.call(&'load_info', info['text'])
			"Character":
				if !show_join_and_leave:
					history_item.queue_free()
					continue
				history_item.call(&'load_info', '[i]'+info['text'])
			"Choice":
				var choices_text: String = ""
				if show_all_choices:
					for i : String in info['all_choices']:
						if i.ends_with('#disabled'):
							choices_text += "-  [i]("+i.trim_suffix('#disabled')+")[/i]\n"
						elif i == info['text']:
							choices_text += "-> [b]"+i+"[/b]\n"
						else:
							choices_text += "-> "+i+"\n"
				else:
					choices_text += "- [b]"+info['text']+"[/b]\n"
				history_item.call(&'load_info', choices_text)

		get_history_log().add_child(history_item)
	
func _init() -> void:
	pass
	
