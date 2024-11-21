extends Node

@onready var stress_bar: TextureRect = $Stressbar_bar
@onready var stress_pointer: AnimatedSprite2D = $StressBar_frame/Stressbar_icon
@onready var stress_bar_bg: TextureRect = $Stressbar_bar_back

var min_stress: float = 0.0
var max_stress: float = 100.0

var current_stress: float = 100
var displayed_stress: float = 100
var target_stress_position: float

var original_bar_width: float
var max_speed = 1.5
var min_speed = 0.75
var lerp_speed: float = 5.0  # Скорость сглаживания изменений

func _ready() -> void:
	original_bar_width = stress_bar.size.x
	Dialogic.signal_event.connect(_on_dialogic_signal)
	update_pointer_position()


func _process(delta: float) -> void:
	displayed_stress = lerp(displayed_stress, current_stress, lerp_speed * delta)
	update_pointer_position()
	update_bar_color()


func increase_stress():
	pass

func decrease_stress():
	pass


func update_bar_color() -> void:
	var current_color: Color 
	if current_stress >= 75:
		current_color = Color(0.73, 0.93, 0.09) # "#baee18"
	elif current_stress >= 50:
		current_color = Color(0.96, 0.65, 0.01) # "#f4a602"
	elif current_stress >= 25:
		current_color = Color(1.0, 0.51, 0.0)   # "#ff8300"
	else:
		current_color = Color(0.9, 0.32, 0.0)   # "#e65100"
	
	stress_bar.modulate = current_color
	stress_pointer.modulate = current_color
	stress_bar_bg.modulate = current_color


func update_pointer_position():
	var progress_ratio = float(displayed_stress - min_stress) / float(max_stress - min_stress)
	progress_ratio = clamp(progress_ratio, 0.0, 1.0)
	
	stress_bar.size.x = original_bar_width * progress_ratio
	
	var min_x = 0.0
	var max_x = original_bar_width
	target_stress_position = lerp(min_x, max_x, progress_ratio)
	
	update_pointer_animation_speed(progress_ratio)


func update_pointer_animation_speed(progress_ratio: float) -> void:
	var animation_speed = lerp(max_speed, min_speed, progress_ratio)
	stress_pointer.speed_scale = animation_speed


func _on_dialogic_signal(argument: Dictionary):
	if argument.has("stress_change"):
		var stress_change_value: float = argument["stress_change"]
		
		current_stress -= stress_change_value
		current_stress = clamp(current_stress, min_stress, max_stress)
		
		if stress_change_value > 0:
			increase_stress()
		else:
			decrease_stress()
