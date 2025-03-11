extends Node

@onready var designer_label: RichTextLabel = $Menu/Designer
@onready var programmer_label: RichTextLabel = $Menu/Programer
@onready var music_label: RichTextLabel = $Menu/Music

var menu = load("res://scenes/start_cutscene.tscn")

func _ready() -> void:
	AudioManager.play_music_loop_with_fade("res://assets/sounds/Do you wanna job.wav")
	
	designer_label.text = tr("DESIGNER") + ": [color=#f3b211]ArchER[/color]"
	programmer_label.text = tr("PROGRAMMER") + ": [color=#f3b211]AlPS_208[/color]"
	music_label.text = tr("MUSICIAN") + ": [color=#f3b211]Boihop[/color]"

func _on_back_pressed() -> void:
	AudioManager.button_play()
	get_tree().change_scene_to_packed(menu)
