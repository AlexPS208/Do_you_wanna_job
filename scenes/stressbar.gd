extends Node

@onready var stress_bar: TextureRect = $StressBarBackground
@onready var stress_pointer: AnimatedSprite2D = $StressBarBackground/StressPointer

@export var min_stress: float = 0.0
@export var max_stress: float = 100.0
var current_stress: float = 50.0
var target_stress_position: float

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	update_pointer_position()

func _process(delta):
	stress_pointer.position.x = lerp(stress_pointer.position.x, target_stress_position, 5 * delta)



func increase_stress():
	pass

func decrease_stress():
	pass

func update_pointer_position():
	var progress_ratio = float(current_stress - min_stress) / float(max_stress - min_stress)
	
	var min_x = 0.0
	var max_x = min_x + stress_bar.size.x

	target_stress_position = lerp(min_x, max_x, progress_ratio)


func _on_dialogic_signal(argument: Dictionary):
	if argument.has("stress_change"):
		var stress_change_value: float = argument["stress_change"]
		
		current_stress += stress_change_value
		current_stress = clamp(current_stress, min_stress, max_stress)
		update_pointer_position()
		
		if stress_change_value > 0:
			increase_stress()
		else:
			decrease_stress()
