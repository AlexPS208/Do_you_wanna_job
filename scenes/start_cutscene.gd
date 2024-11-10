extends Node3D

@onready var cutscene_animator: AnimationPlayer = $Cutscene_animation

var first_manager_scene = preload("res://scenes/First_manager.tscn")

func _ready() -> void:
	cutscene_animator.play("Cutscene")


func _on_cutscene_animation_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(first_manager_scene)
