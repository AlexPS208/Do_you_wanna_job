extends Node

@onready var music_player = $Music
@onready var ambient_player = $Ambient

var music_fade_duration: float = 10.0
var original_music_volume_db: float = -35.0
var current_music_volume_db: float = -80.0
var target_music_volume_db: float


func _process(delta: float) -> void:
	if current_music_volume_db != target_music_volume_db:
		current_music_volume_db = lerp(current_music_volume_db, target_music_volume_db, delta * music_fade_duration)
		music_player.volume_db = current_music_volume_db


func play_music_once(audio_path: String) -> void:
	music_player.stream = load(audio_path)
	music_player.play()

func play_music_loop_with_fade(audio_path: String) -> void:
	music_player.stream = load(audio_path)
	target_music_volume_db = original_music_volume_db
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func set_music_volume(target_db: float, duration_coef: float) -> void:
	target_music_volume_db = target_db
	music_fade_duration = duration_coef

func set_original_music_volume(duration_coef: float) -> void:
	target_music_volume_db = original_music_volume_db
	music_fade_duration = duration_coef


func _on_music_finished() -> void:
	play_music_loop_with_fade(music_player.stream.resource_path)



func play_ambient(audio_path: String) -> void:
	music_player.stream = load(audio_path)
	music_player.play()
