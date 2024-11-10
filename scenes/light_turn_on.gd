extends ColorRect

@onready var lamp_animator: AnimationPlayer = $Lamp_animator

func _ready() -> void:
	lamp_animator.play("Light_turn_on")
