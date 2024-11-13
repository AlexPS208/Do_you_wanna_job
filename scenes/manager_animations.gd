extends Node3D

@onready var head: AnimatedSprite3D = $Manager_head
@onready var hands: AnimatedSprite3D = $Manager_hands

# Signals params
var animation_name: String = ""
var end_sprite_name: String = ""
var target_part: String = ""
var loops: int = 1

var animation_sprites_names: Array = []


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_dialogic_signal(params: Dictionary):
	if params.has("part") and params.has("animation") and params.has("end_sprite") and params.has("loops"):
		target_part = params["part"]
		animation_name = params["animation"]
		end_sprite_name = params["end_sprite"]
		loops = params["loops"]

	if target_part == "head":
		if animation_name == "speak_unserious":
			animation_sprites_names = ["quiet_open_unserious", "speak_open_unserious"]
		elif animation_name == "speak_serious":
			animation_sprites_names = ["quiet_open_serious", "speak_open_serious"]
		elif animation_name == "smile_serious":
			animation_sprites_names = ["smile_open_serious", "speak_open_serious"]
			
		
		start_head_animation()


func start_head_animation() -> void:
	await get_tree().create_timer(0.1).timeout
	for loop in range(loops-1):
		for sprite in animation_sprites_names:
			head.play(sprite)
			await get_tree().create_timer(0.125).timeout
	head.play(end_sprite_name)
