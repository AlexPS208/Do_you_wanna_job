extends Node3D

@onready var cutscene_animator: AnimationPlayer = $Cutscene_animation
@onready var menu_panel: Control = $UI/Menu
@onready var door: CSGBox3D = $Scene/Door
@onready var button_sound: AudioStreamPlayer3D = $UI/Button_sound

var first_manager_scene = preload("res://scenes/First_manager.tscn")

func _ready() -> void:
	AudioManager.play_ambient("res://assets/sounds/whispers.mp3")
	

func _on_cutscene_animation_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(first_manager_scene)


func _on_start_pressed() -> void:
	button_sound.play()
	menu_panel.visible = false
	cutscene_animator.play("Cutscene")


func _on_exit_pressed() -> void:
	button_sound.play()
	get_tree().quit()
