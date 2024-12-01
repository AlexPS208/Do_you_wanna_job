extends Node

@onready var music_player = $Music
@onready var music_double_player = $Music/Music
@onready var ambient_player = $Ambient
@onready var clock_player = $Clock
@onready var clock_double_player = $Clock/Clock
@onready var stress_hit = $Stress_hit
@onready var stress_heal = $Stress_heal

# Музыка
var music_fade_duration: float = 10.0
var original_music_volume_db: float = -20.0
var current_music_volume_db: float = -80.0
var target_music_volume_db: float

# Эмбиент
var ambient_fade_duration: float = 10.0
var original_ambient_volume_db: float = -25.0
var current_ambient_volume_db: float = -80.0
var target_ambient_volume_db: float

# Сердцебиение
var clock_fade_duration: float = 0.15
var original_clock_volume_db: float = -5.0
var current_clock_volume_db: float = -80.0
var target_clock_volume_db: float = -15.0

# Движение
var move_speed: float = 2.0
var target_x_positions: Array = [2.0, -2.0, 0.0]
var current_target_index: int = 0

var master_volume: float = 1.0

func _ready():
	set_master_volume(master_volume)


func _process(delta: float) -> void:
	# Плавное изменение громкости музыки
	if current_music_volume_db != target_music_volume_db:
		current_music_volume_db = lerp(current_music_volume_db, target_music_volume_db, delta * music_fade_duration)
		music_player.volume_db = current_music_volume_db
		music_double_player.volume_db = current_music_volume_db

	# Плавное изменение громкости эмбиента
	if current_ambient_volume_db != target_ambient_volume_db:
		current_ambient_volume_db = lerp(current_ambient_volume_db, target_ambient_volume_db, delta * ambient_fade_duration)
		ambient_player.volume_db = current_ambient_volume_db

	if current_clock_volume_db != target_clock_volume_db:
		current_clock_volume_db = lerp(current_clock_volume_db, target_clock_volume_db, delta * clock_fade_duration)
		clock_player.volume_db = current_clock_volume_db

	# Плавное движение узла
	if current_target_index < target_x_positions.size():
		move_to_target(delta)


# Управление музыкой
func play_music_once(audio_path: String) -> void:
	music_player.stream = load(audio_path)
	music_player.play()

func play_music_loop_with_fade(audio_path: String) -> void:
	music_player.stream = load(audio_path)
	music_double_player.stream = load(audio_path)
	target_music_volume_db = original_music_volume_db
	music_player.play()
	music_double_player.play()

func stop_music() -> void:
	music_player.stop()
	music_double_player.stop()

func set_music_volume(target_db: float, duration_coef: float) -> void:
	target_music_volume_db = target_db
	music_fade_duration = duration_coef

func set_original_music_volume(duration_coef: float) -> void:
	target_music_volume_db = original_music_volume_db
	music_fade_duration = duration_coef


# Управление эмбиентом
func play_ambient(audio_path: String) -> void:
	ambient_player.stream = load(audio_path)
	target_ambient_volume_db = original_ambient_volume_db
	ambient_player.play()

func stop_ambient() -> void:
	ambient_player.stop()

func set_ambient_volume(target_db: float, duration_coef: float) -> void:
	target_ambient_volume_db = target_db
	ambient_fade_duration = duration_coef

func set_original_ambient_volume(duration_coef: float) -> void:
	target_ambient_volume_db = original_ambient_volume_db
	ambient_fade_duration = duration_coef


# Управление звуком часов
func start_clock(audio_path: String) -> void:
	clock_player.stream = load(audio_path)
	set_clock_volume(original_clock_volume_db, clock_fade_duration)
	clock_player.play()

func stop_clock() -> void:
	set_clock_volume(-80.0, 2.0)
	await get_tree().create_timer(3).timeout
	clock_player.stop()

func set_clock_volume(target_db: float, duration_coef: float) -> void:
	target_clock_volume_db = target_db
	clock_fade_duration = duration_coef


# Движение
func move_to_target(delta: float):
	var current_position = ambient_player.global_transform.origin
	var target_position = target_x_positions[current_target_index]

	current_position.x = lerp(current_position.x, target_position, move_speed * delta)

	ambient_player.global_transform.origin = current_position
	clock_player.global_transform.origin = current_position

	if abs(current_position.x - target_position) < 0.01:
		current_target_index += 1


# Stress damage and heal
func hit() -> void:
	stress_hit.play()

func heal() -> void:
	stress_heal.play()


func start_timer() -> void:
	clock_double_player.play()

func stop_timer() -> void:
	clock_double_player.stop()


# События завершения
func _on_music_finished() -> void:
	play_music_loop_with_fade(music_player.stream.resource_path)

func _on_ambient_finished() -> void:
	play_ambient(ambient_player.stream.resource_path)




func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 2.0)  # Ограничиваем значение
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

# Логарифмическое преобразование громкости
func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	elif value == 1.0:
		return 0.0
	else:
		return 20.0 * log(value) / log(2) 


func _on_h_slider_value_changed(value: float) -> void:
	set_master_volume(value)
