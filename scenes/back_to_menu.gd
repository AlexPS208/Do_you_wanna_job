extends Node

@onready var button_sound: AudioStreamPlayer3D = $Button_sound

var menu = preload("res://scenes/start_cutscene.tscn")


func _ready() -> void:
	AudioManager.play_music_loop_with_fade("res://assets/sounds/Do you wanna job.wav")


func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_packed(menu)
