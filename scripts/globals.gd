extends Node

const dev = preload("res://Characters/dev_resource.tres")
const bar = preload("res://Characters/bar_resource.tres")
const cons = preload("res://Characters/console_resource.tres")
const body = preload("res://Characters/body_resource.tres")

const characters := {
	"DEV":dev,
	"BAR":bar,
	"CONS":cons,
	"BODY":body
}

var character_dict := {
	"ID" : "",
	"name" : "",
	"active" : false,
	"flags" : {},
	"sprite" : ""
}

var character_stats := {}

##For statement rotates through each character in the character list and assigns based off of resource
func create_character_dict(c: CharacterResource) -> Dictionary:
	var new_dict = character_dict.duplicate()
	new_dict.ID = c.character_id
	new_dict.name = c.character_name
	new_dict.active = c.character_active
	new_dict.flags = c.character_flags
	new_dict.sprite = c.sprite_path
	print(new_dict, "-> Created dictionary")
	return new_dict

#For statement cycles through character list and populates each character's stats
func create_character_stats():
	for i in characters:
		character_stats[characters[i].character_id] = create_character_dict(characters[i])
	print(character_stats, "-> Created stat block")
	
func clear_character_dict() -> void:
	character_dict.clear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
