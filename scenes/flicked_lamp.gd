extends Node3D

@export var FLASH_ENERGY_OMNI: float = 1.0
@export var FLASH_ENERGY_SPOT: float = 1.0
@export var min_flickless_time: float = 5.0
@export var max_flickless_time: float = 10.0

# Списки для OmniLight и SpotLight
@onready var omni_lights = [$OmniLight3D1, $OmniLight3D2, $OmniLight3D3]
@onready var spot_lights = [$SpotLight3D1, $SpotLight3D2, $SpotLight3D3]

# Таймеры
@onready var flicker_timer: Timer = $Flicker_timer
@onready var flicker_duration_timer: Timer = $Flicker_duration_timer

# Внутренние переменные
var is_flickering = false
var flicker_count = 0
var flicker_target_count = 0

func _ready() -> void:
	# Начальная настройка таймеров
	flicker_timer.wait_time = randf_range(min_flickless_time, max_flickless_time)
	flicker_timer.start()

func _on_flicker_timer_timeout() -> void:
	is_flickering = true
	flicker_count = 0
	flicker_target_count = randi_range(5, 20)
	_on_flicker_duration_timer_timeout()  # Запуск первого мигания сразу же

func _on_flicker_duration_timer_timeout() -> void:
	if flicker_count < flicker_target_count:
		if flicker_count % 2 == 0:
			# Отключаем свет у всех источников
			for i in range(omni_lights.size()):
				omni_lights[i].light_energy = 0
				spot_lights[i].light_energy = 0
		else:
			# Включаем свет с случайной интенсивностью
			var flicker_coeff: float = randf_range(0, 1)
			for i in range(omni_lights.size()):
				omni_lights[i].light_energy = FLASH_ENERGY_OMNI * flicker_coeff
				spot_lights[i].light_energy = FLASH_ENERGY_SPOT * flicker_coeff

		# Запускаем таймер для следующего мигания
		flicker_duration_timer.wait_time = 0.05
		flicker_duration_timer.start()
		flicker_count += 1
	else:
		# Окончание мигания
		is_flickering = false
		for i in range(omni_lights.size()):
			omni_lights[i].light_energy = FLASH_ENERGY_OMNI
			spot_lights[i].light_energy = FLASH_ENERGY_SPOT

		# Перезапуск таймера для случайного интервала без мигания
		if flicker_timer.is_stopped():
			flicker_timer.wait_time = randf_range(min_flickless_time, max_flickless_time)
			flicker_timer.start()
