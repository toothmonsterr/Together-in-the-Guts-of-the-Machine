extends VBoxContainer


func get_text_box() -> RichTextLabel:
	return $ConsoleText

func load_info(text:String, character:String = "", character_color: Color =Color(), icon:Texture= null) -> void:
	get_text_box().text = text
