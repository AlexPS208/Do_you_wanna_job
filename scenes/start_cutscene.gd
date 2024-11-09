extends Node3D

@onready var cutscene_animator: AnimationPlayer = $Cutscene_animation

func _ready() -> void:
	cutscene_animator.play("Cutscene")
