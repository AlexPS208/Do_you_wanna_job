extends Node

@onready var stress_bar: TextureRect = $StressBarBackground
@onready var stress_pointer: TextureRect = $StressBarBackground/StressPointer

@export var min_stress: int = 0
@export var max_stress: int = 100
var current_stress: int = 50
var target_stress_position: float

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	update_pointer_position()

# Плавное обновление позиции указателя
func _process(delta):
	stress_pointer.position.x = lerp(stress_pointer.position.x, target_stress_position, 5 * delta)


func increase_stress(amount: int):
	current_stress += amount
	current_stress = clamp(current_stress, min_stress, max_stress)
	update_pointer_position()

func decrease_stress(amount: int):
	current_stress -= amount
	current_stress = clamp(current_stress, min_stress, max_stress)
	update_pointer_position()

func update_pointer_position():
	var progress_ratio = float(current_stress - min_stress) / float(max_stress - min_stress)
	
	var min_x = 0.0
	var max_x = min_x + stress_bar.size.x - stress_pointer.size.x

	target_stress_position = lerp(min_x, max_x, progress_ratio)


func _on_dialogic_signal(argument: String):
	if argument == "stress_increase":
		increase_stress(5)
	elif argument == "stress_decrease":
		decrease_stress(5)
