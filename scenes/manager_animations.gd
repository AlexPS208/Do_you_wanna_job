extends Node3D

@onready var head: AnimatedSprite3D = $Manager_head
@onready var hands: AnimatedSprite3D = $Manager_hands
@onready var voice: AudioStreamPlayer3D = $Manager_voice
@onready var blink_timer: Timer = $Manager_blink_timer

# Signals params
var animation_name: String = ""
var end_sprite_name: String = ""
var target_part: String = ""
var loops: int = 1

var animation_sprites_names: Array = []
var is_blink_allowed: bool = true


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	reset_blink_timer()


func reset_blink_timer() -> void:
	blink_timer.wait_time = randf_range(2.0, 4.0)
	blink_timer.start()
	

func _on_dialogic_signal(params: Dictionary):
	if params.has("part") and params.has("animation") and params.has("end_sprite") and params.has("loops"):
		target_part = params["part"]
		animation_name = params["animation"]
		end_sprite_name = params["end_sprite"]
		loops = params["loops"]
	elif params.has("part") and params.has("loops"):
		target_part = params["part"]
		loops = params["loops"]


	if target_part == "head":
		if animation_name == "speak_unserious":
			animation_sprites_names = ["quiet_open_unserious", "speak_open_unserious"]
		elif animation_name == "speak_serious":
			animation_sprites_names = ["quiet_open_serious", "speak_open_serious"]
		elif animation_name == "speak_surprised":
			animation_sprites_names = ["quiet_open_surprised", "speak_open_surprised"]
		elif animation_name == "smile_serious":
			animation_sprites_names = ["smile_open_serious", "speak_open_serious"]
		
		start_head_animation()
		target_part = ""
	
	if target_part == "player_voice":
		start_voice_animation()


func start_head_animation() -> void:
	is_blink_allowed = false
	await get_tree().create_timer(0.1).timeout
	for loop in range(loops-1):
		for sprite in animation_sprites_names:
			head.play(sprite)
			voice.play()
			await get_tree().create_timer(0.125).timeout
	head.play(end_sprite_name)
	reset_blink_timer()
	is_blink_allowed = true

func start_voice_animation() -> void:
	await get_tree().create_timer(0.1).timeout
	voice.pitch_scale += 0.5
	for loop in range(loops-1):
		for sprite in animation_sprites_names:
			voice.play()
			await get_tree().create_timer(0.125).timeout
	voice.pitch_scale -= 0.5


# Blink animation
func _on_manager_blink_timer_timeout() -> void:
	if head.animation.contains("open") and is_blink_allowed:
		var open_state = head.animation
		var close_state = open_state.replace("open", "close")
		for i in range(randi_range(1, 2)):
			head.play(close_state)
			await get_tree().create_timer(0.125).timeout
			head.play(open_state)
			await get_tree().create_timer(0.125).timeout
	reset_blink_timer()
