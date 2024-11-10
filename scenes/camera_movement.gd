extends Camera3D

var rotation_sensitivity: float = 0.01
var max_rotation_angle: float = deg_to_rad(2.5)

# Начальный угол поворота
var base_rotation: Vector3 = Vector3()

func _ready():
	# Сохраняем начальный угол поворота камеры
	base_rotation = rotation_degrees

func _process(delta):
	# Получаем координаты мыши
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	var offset_x = (mouse_pos.x - screen_size.x / 2) / (screen_size.x / 2)
	var offset_y = (mouse_pos.y - screen_size.y / 2) / (screen_size.y / 2)

	var target_rotation_x = clamp(offset_y * max_rotation_angle, -max_rotation_angle, max_rotation_angle)
	var target_rotation_y = clamp(-offset_x * max_rotation_angle, -max_rotation_angle, max_rotation_angle)

	rotation_degrees.x = lerp(rotation_degrees.x, base_rotation.x - rad_to_deg(target_rotation_x), rotation_sensitivity)
	rotation_degrees.y = lerp(rotation_degrees.y, base_rotation.y + rad_to_deg(target_rotation_y), rotation_sensitivity)
