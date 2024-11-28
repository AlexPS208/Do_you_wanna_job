extends Node3D

@onready var head: AnimatedSprite3D = $Manager_head
@onready var hands: AnimatedSprite3D = $Manager_hands
@onready var voice: AudioStreamPlayer3D = $Manager_voice
@onready var blink_timer: Timer = $Manager_blink_timer

# Signals params for head
var head_animation_name: String = ""
var head_end_sprite_name: String = ""
var head_loops: int = 1
var head_animation_sprites_names: Array = []

# Signals params for hands
var hand_animation_name: String = ""
var hand_end_sprite_name: String = ""
var hand_loops: int = 1

var is_blink_allowed: bool = true
var is_animation_playing: bool = false


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	reset_blink_timer()


	

func _on_dialogic_signal(params: Dictionary):
	# Parameters for head
	if params.has("part") and params["part"] == "head":
		if params.has("animation") and params.has("end_sprite") and params.has("loops"):
			head_animation_name = params["animation"]
			head_end_sprite_name = params["end_sprite"]
			head_loops = params["loops"]

			if head_animation_name == "speak_surprised_serious":
				head_animation_sprites_names = ["quiet_surprised_serious", "speak_surprised_serious"]
			elif head_animation_name == "speak_surprised_smile":
				head_animation_sprites_names = ["quiet_surprised_smile", "speak_surprised_smile"]
			elif head_animation_name == "speak_open_serious":
				head_animation_sprites_names = ["quiet_open_serious", "speak_open_serious"]
			elif head_animation_name == "speak_close_serious":
				head_animation_sprites_names = ["quiet_close_serious", "speak_close_serious"]
			elif head_animation_name == "speak_open_smile":
				head_animation_sprites_names = ["quiet_open_smile", "speak_open_smile"]
			elif head_animation_name == "speak_close_smile":
				head_animation_sprites_names = ["quiet_close_smile", "speak_close_smile"]

			start_head_animation()

	# Parameters for hands
	elif params.has("part") and params["part"] == "hand":
		if params.has("animation") and params.has("end_sprite") and params.has("loops"):
			hand_animation_name = params["animation"]
			hand_end_sprite_name = params["end_sprite"]
			hand_loops = params["loops"]

			start_hand_animation(hand_animation_name, hand_end_sprite_name)



func start_head_animation() -> void:
	is_blink_allowed = false
	is_animation_playing = true
	blink_timer.stop()  # Stop blinking timer
	await get_tree().create_timer(0.1).timeout

	for loop in range(head_loops - 1):
		for sprite in head_animation_sprites_names:
			head.play(sprite)
			voice.play()
			await get_tree().create_timer(0.15).timeout

	head.play(head_end_sprite_name)
	is_animation_playing = false
	reset_blink_timer()
	is_blink_allowed = true


func start_hand_animation(sprite: String, end_sprite: String):
	hands.play(sprite)
	await get_tree().create_timer(0.5 * hand_loops).timeout
	hands.play(end_sprite)



# Blink animation
func _on_manager_blink_timer_timeout() -> void:
	if head.animation.contains("open") and is_blink_allowed and not is_animation_playing:
		var open_state = head.animation
		if open_state == "quiet_open_serious" or open_state == "quiet_open_smile":
			var close_state = open_state.replace("open", "close")
			head.play(close_state)
	
	reset_blink_timer()



func reset_blink_timer() -> void:
	if not is_animation_playing:
		blink_timer.wait_time = randf_range(3.0, 5.0)
		blink_timer.start()
