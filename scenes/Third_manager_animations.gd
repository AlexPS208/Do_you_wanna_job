extends Node3D

@onready var head: AnimatedSprite3D = $Manager_head
@onready var hands: AnimatedSprite3D = $Manager_body
@onready var voice: AudioStreamPlayer3D = $Manager_voice
@onready var blink_timer: Timer = $Manager_blink_timer
@onready var change_sound: AudioStreamPlayer3D = $Manager_neck

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


			# VICTIM
			if head_animation_name == "sad_speak_open":
				head_animation_sprites_names = ["sad_open_quiet", "sad_open_speak"]
			elif head_animation_name == "sad_speak_close":
				head_animation_sprites_names = ["sad_close_quiet", "sad_close_speak"]
			elif head_animation_name == "sad_cry_open":
				head_animation_sprites_names = ["sad_open_speak", "sad_open_cry"]
			elif head_animation_name == "sad_speak_surprised":
				head_animation_sprites_names = ["sad_surprised_quiet", "sad_surprised_speak"]
			elif head_animation_name == "sad_cry_surprised":
				head_animation_sprites_names = ["sad_surprised_speak", "sad_surprised_cry"]
			
			# MANIAC
			elif head_animation_name == "happy_speak_open":
				head_animation_sprites_names = ["happy_open_quiet", "happy_open_speak"]
			elif head_animation_name == "happy_speak_close":
				head_animation_sprites_names = ["happy_close_quiet", "happy_close_speak"]
			elif head_animation_name == "happy_smile_open":
				head_animation_sprites_names = ["happy_open_speak", "happy_open_smile"]
			elif head_animation_name == "happy_smile_close":
				head_animation_sprites_names = ["happy_close_speak", "happy_close_smile"]
			
			# CREEP
			elif head_animation_name == "creep_speak":
				head_animation_sprites_names = ["creep_quiet", "creep_speak"]
			elif head_animation_name == "creep_laught":
				head_animation_sprites_names = ["creep_laught"]
			elif head_animation_name == "change":
				change_sound.play()
				head_animation_sprites_names = ["change"]

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
			await get_tree().create_timer(0.125).timeout

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
		var close_state = open_state.replace("open", "close")
		for i in range(randi_range(1, 2)):
			head.play(close_state)
			await get_tree().create_timer(0.125).timeout
			head.play(open_state)
			await get_tree().create_timer(0.125).timeout
	reset_blink_timer()



func reset_blink_timer() -> void:
	if not is_animation_playing:
		blink_timer.wait_time = randf_range(2.0, 4.0)
		blink_timer.start()
