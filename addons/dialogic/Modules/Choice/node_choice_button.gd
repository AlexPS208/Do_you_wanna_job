class_name DialogicNode_ChoiceButton
extends Button
## The button allows the player to make a choice in the Dialogic system.
##
## This class is used in the Choice Layer. [br]
## You may change the [member text_node] to any [class Node] that has a
## `text` property. [br]
## If you don't set the [member text_node], the text will be set on this
## button instead.
##
## Using a different node may allow using rich text effects; they are
## not supported on buttons at this point.

## Used to identify what choices to put on. If you leave it at -1, choices will be distributed automatically.
@export var choice_index: int = -1

## Can be set to play this sound when pressed. Requires a sibling DialogicNode_ButtonSound node.
@export var sound_pressed: AudioStream
## Can be set to play this sound when hovered. Requires a sibling DialogicNode_ButtonSound node.
@export var sound_hover: AudioStream
## Can be set to play this sound when focused. Requires a sibling DialogicNode_ButtonSound node.
@export var sound_focus: AudioStream
## If set, the text will be set on this node's `text` property instead.

@export var text_node: RichTextLabel



func _ready() -> void:
	add_to_group('dialogic_choice_button')
	shortcut_in_tooltip = false
	hide()


func _load_info(choice_info: Dictionary) -> void:
	set_choice_text(choice_info.text)
	visible = choice_info.visible
	disabled = choice_info.disabled


func set_choice_text(new_text: String) -> void:
	if text_node and text_node is RichTextLabel:
		text = " "
		#text_node.bbcode_text = "[center]" + new_text + "[/center]"
		text_node.bbcode_text = "[b]    " + new_text + "[/b]"
	else:
		text = new_text
	
	# Удаление BBCode тегов
	var regex = RegEx.new()
	regex.compile(r"\[.*?\]")
	var clean_text = regex.sub(new_text, "")
	
	var text_length = clean_text.length()
	var padding = 5
	var width = text_length * 12 + padding
	
	custom_minimum_size = Vector2(600, 29)


## Called when the text changes.
#func set_choice_text(new_text: String) -> void:
	#if text_node:
		#text_node.text = new_text
	#else:
		#text = new_text
