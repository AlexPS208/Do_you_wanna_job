extends CanvasLayer

@onready var scene_animator: AnimationPlayer = $"../Under_UI_effects/Scene_transit_start/Lamp_animator"

@onready var menu: Control = $Menu
@onready var menu_panel: ColorRect = $Menu/MenuPanel
@onready var exit_pre_confirm_panel: ColorRect = $Menu/Exit_pre_confirm
@onready var exit_confirm_panel: ColorRect = $Menu/Exit_confirm
@onready var button_sound: AudioStreamPlayer3D = $Button_sound

@onready var timebar: Node = $Timebar
@onready var timebar_bar: TextureRect = $Timebar/Timebar_bar
@onready var timer: Timer = $Timebar/Timer
@onready var timebar_animator: AnimationPlayer = $Timebar/Timebar_animator

@onready var sight: TextureRect = $"../Under_UI_effects/Sight_texture"
@onready var camera: Camera3D = $"../Camera3D"
@onready var question_counter: Label = $Timebar/Timebar_frame/Question_counter
@onready var silentbar_animator: AnimationPlayer = $Silentbar/Silentbar_animator

@onready var stress_bar: TextureRect = $Stressbar/Stressbar_bar
@onready var stress_pointer: AnimatedSprite2D = $Stressbar/StressBar_frame/Stressbar_icon
@onready var stress_pointer_cut: AnimatedSprite2D = $Stressbar/StressBar_frame/Stress_icon_cut
@onready var stress_bar_bg: TextureRect = $Stressbar/Stressbar_bar_back
@onready var stressbar_animator: AnimationPlayer = $Stressbar/Stressbar_animator

#@onready var painting: AnimatedSprite3D = $"../Scene/Decor/Art2"
@onready var whispers: AudioStreamPlayer3D = $"../Scene/Decor/Ventilation/Whispers"


# Menu
var is_menu_active: bool = false
var is_menu_panel_active: bool = false
var is_pre_confirm_active: bool = false
var is_confirm_active: bool = false

# Dialogic
var dialog_node
var current_skip_choice: int = 0

# Timebar
var original_timebar_width: float
var original_timebar_position: Vector2
var is_timebar_hide: bool = true

# Timer animation
var original_fov: float = 70.0
var target_fov: float = 60.0
var original_sight_color: Color = Color(1, 1, 1, 0)  # ffffff00
var target_sight_color: Color = Color(1, 1, 1, 1)    # ffffff
var lerp_speed: float = 0.3

# Questions
var questions_value = 11
var current_question_number = 0

var main_labels = ["main_01", "main_02", "main_03", "main_04", "main_05", "main_06", "main_07", "main_08", "main_09", "main_10", "main_11", "main_12"]
var event_labels = ["event_01", "event_02"]
var used_labels = []

var is_art_event: bool = false
var is_whispers_event: bool = false


# Stressbar
var min_stress: float = 0.0
var max_stress: float = 100.0

var current_stress: float = 100
var displayed_stress: float = 100
var target_stress_position: float

var stressbar_original_width: float
var stressbar_max_speed = 0.75
var stressbar_min_speed = 0.75
var stressbar_lerp_speed: float = 5.0

var silent_answers: int = 3
var is_player_dead: bool = false



func _ready() -> void:
	stressbar_original_width = stress_bar.size.x
	update_pointer_position()
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("Second_cutscene")
	
	original_timebar_width = timebar_bar.size.x
	original_timebar_position = timebar_bar.position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if is_player_dead:
			return
		
		button_sound.play()
		if !is_menu_active:
			show_menu()
		else:
			hide_menu()
	
	if !timer.is_stopped():
		var remaining_time = timer.time_left
		var total_time = timer.wait_time
		update_timebar(total_time, remaining_time)
		camera.fov = lerp(camera.fov, target_fov, lerp_speed * delta)
		sight.modulate = sight.modulate.lerp(target_sight_color, lerp_speed * delta)
	else:
		camera.fov = lerp(camera.fov, original_fov, lerp_speed * delta * 15)
		sight.modulate = sight.modulate.lerp(original_sight_color, lerp_speed * delta * 15)
	
	if current_stress <= 0 or silent_answers <= 0:
		death()
	
	displayed_stress = lerp(displayed_stress, current_stress, stressbar_lerp_speed * delta)
	update_pointer_position()
	update_bar_color()



func _simulate_keypress(action_name: String):
	Input.action_press(action_name)
	Input.action_release(action_name)

func show_menu() -> void:
	get_tree().paused = true
	
	menu_panel.visible = true
	is_menu_active = true
	is_menu_panel_active = true
	
	exit_pre_confirm_panel.visible = false
	is_pre_confirm_active = false
	AudioManager.set_music_volume(-45.0, 5.0)
	AudioManager.set_ambient_volume(-45.0, 5.0)
	
	toggle_dialogic_layer(true)


func hide_menu() -> void:
	get_tree().paused = false
	
	menu_panel.visible = false
	exit_pre_confirm_panel.visible = false
	exit_confirm_panel.visible = false
	
	is_menu_active = false
	is_pre_confirm_active = false
	is_confirm_active = false
	AudioManager.set_original_music_volume(5.0)
	AudioManager.set_original_ambient_volume(5.0)
	
	toggle_dialogic_layer(false)


func show_pre_confirm() -> void:
	menu_panel.visible = false
	is_menu_panel_active = false
	
	exit_pre_confirm_panel.visible = true
	is_pre_confirm_active = true
	
	exit_confirm_panel.visible = false
	is_confirm_active = false


func show_confirm() -> void:
	exit_pre_confirm_panel.visible = false
	is_pre_confirm_active = false

	exit_confirm_panel.visible = true
	is_confirm_active = true


# DIALOGIC
func toggle_dialogic_layer(is_menu_open: bool):
	if is_menu_open:
		Dialogic.paused = true
	else:
		Dialogic.paused = false


func _on_dialogic_signal(argument: Dictionary):
	if argument.has("light_on"):
		await get_tree().create_timer(1).timeout
		scene_animator.play("Light_turn_on")
		AudioManager.play_music_loop_with_fade("res://assets/sounds/Old_music.wav")
		AudioManager.play_ambient("res://assets/sounds/office_ambient.wav")
		await get_tree().create_timer(1).timeout
		dialog_node = Dialogic.start("Second_manager")

	
	# Timebar
	if argument.has("start_timer"):
		var duration = argument["start_timer"]
		current_skip_choice = argument["skip_choice"]
		start_timer(duration)
	if argument.has("stop_timer"):
		stop_timer()
		if argument["is_answered"]:
			if is_timebar_hide:
				timebar_animator.play("timebar_show")
				is_timebar_hide = false
				await get_tree().create_timer(0.4).timeout
			decrease_questions_value()
		elif !argument["is_answered"] and argument["is_silent"]:
			silent_answer()
	if argument.has("show_stressbar"):
		if argument["show_stressbar"]:
			stressbar_animator.play("stressbar_show")
	if argument.has("show_silentbar"):
		if argument["show_silentbar"]:
			silentbar_animator.play("show_pointers")
			
	
	# Random question & events
	if argument.has("random_question"):
		random_jump()
	if argument.has("event"):
		event_start()
		if argument["event"] == "art":
			event_art_start()
		if argument["event"] == "whispers":
			event_whispers_start()
	if argument.has("event_end"):
		if argument["event_end"]:
			event_end()
			if is_art_event:
				event_art_end()
			if is_whispers_event:
				event_whispers_end()
	
	# Stressbar
	if argument.has("stress_change"):
		var stress_change_value: float = argument["stress_change"]
		if stress_change_value > 0:
			stress_pointer_cut.play("cut")
			stressbar_animator.play("stress_hit")
		
		current_stress -= stress_change_value
		current_stress = clamp(current_stress, min_stress, max_stress)
	
	# Win
	if argument.has("end_manager"):
		if argument["end_manager"]:
			win_animation_start()


# RANDOM QUESTION
func random_jump():
	if questions_value <= 0:
		Dialogic.Jump.jump_to_label("End")
		return
	
	var current_block
	current_question_number += 1
	if current_question_number in [4, 12]:
		current_block = event_labels
	else:
		current_block = main_labels
	
	
	var available_labels = []
	
	for label in current_block:
		if not used_labels.has(label):
			available_labels.append(label)

	
	if available_labels.size() > 0:
		var random_label = available_labels[randi() % available_labels.size()]
		Dialogic.Jump.jump_to_label(random_label)
		used_labels.append(random_label)
	else:
		Dialogic.Jump.jump_to_label("End")


func decrease_questions_value() -> void:
	timebar_animator.play("Questions_counter_hide")
	await get_tree().create_timer(0.2).timeout
	questions_value -= 1
	question_counter.text = str(questions_value)
	timebar_animator.play("Questions_counter_show")


# EVENTS
func event_start() -> void:
	timebar_animator.play("event_start")

func event_end() -> void:
	timebar_animator.play("event_end")

func event_art_start():
	is_art_event = true
	#painting.play("event_start")

func event_art_end():
	is_art_event = false
	#painting.play("event_end")

func event_whispers_start():
	is_whispers_event = true
	whispers.play()

func event_whispers_end():
	is_whispers_event = false
	whispers.stop()


# TIMER AND TIMEBAR
func start_timer(duration: float) -> void:
	timebar_bar.size.x = original_timebar_width
	timebar_bar.position.x = original_timebar_position.x
	stress_pointer.play("beat")

	if current_stress >= 50:
		AudioManager.set_music_volume(-50.0, 1.0)
	else:
		AudioManager.set_music_volume(0.0, 1.0)
	AudioManager.set_ambient_volume(-45.0, 1.0)
	AudioManager.start_clock("res://assets/sounds/Heartbeat.mp3")
	timer.wait_time = duration
	timer.start()

func _on_timer_timeout() -> void:
	focus_on_skip_choice()
	get_viewport().gui_get_focus_owner().pressed.emit()
	stop_timer()

func stop_timer() -> void:
	if !timer.is_stopped():
		AudioManager.set_original_music_volume(5.0)
		AudioManager.set_original_ambient_volume(5.0)
		AudioManager.stop_clock()
		stress_pointer.play("idle")
		timer.stop()
		timebar_bar.position.x = original_timebar_position.x
		timebar_bar.size.x = original_timebar_width

func focus_on_skip_choice():
	for button in get_tree().get_nodes_in_group("dialogic_choice_button"):
		if button.name == "DialogicNode_ChoiceButton" + str(current_skip_choice):
			button.grab_focus()

func update_timebar(total_time: float, remaining_time: float) -> void:
	var progress_ratio = remaining_time / total_time
	progress_ratio = clamp(progress_ratio, 0.0, 1.0)

	var new_width = original_timebar_width * progress_ratio
	timebar_bar.size.x = new_width
	timebar_bar.position.x = original_timebar_position.x + (original_timebar_width - new_width)

func silent_answer():
	silentbar_animator.play("remove_point_" + str(silent_answers))
	silent_answers -= 1
	

# STRESSBAR
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
	
	stress_bar.size.x = stressbar_original_width * progress_ratio
	
	var min_x = 0.0
	var max_x = stressbar_original_width
	target_stress_position = lerp(min_x, max_x, progress_ratio)
	
	update_pointer_animation_speed(progress_ratio)


func update_pointer_animation_speed(progress_ratio: float) -> void:
	var animation_speed = lerp(stressbar_max_speed, stressbar_min_speed, progress_ratio)
	stress_pointer.speed_scale = animation_speed


# END ANIMATIONS
func death():
	if is_player_dead:
		return
	
	Dialogic.Jump.jump_to_label("death")
	Dialogic.Inputs.auto_advance.enabled_until_next_event = true
	AudioManager.start_clock("res://assets/sounds/Heartbeat.mp3")
	is_player_dead = true
	scene_animator.play("death_animation")

func win_animation_start():
	is_player_dead = true
	scene_animator.play("win_animation")



# BUTTONS
func _on_resume_pressed() -> void:
	button_sound.play()
	hide_menu()

func _on_exit_pressed() -> void:
	button_sound.play()
	show_pre_confirm()


func _on_pre_exit_pressed() -> void:
	button_sound.play()
	show_confirm()

func _on_pre_cancel_pressed() -> void:
	button_sound.play()
	show_menu()


func _on_exit_confirmed_pressed() -> void:
	button_sound.play()
	get_tree().quit()

func _on_cancel_pressed() -> void:
	button_sound.play()
	show_pre_confirm()


# RESTART SCENE
func _on_restart_pressed() -> void:
	AudioManager.stop_clock()
	get_tree().reload_current_scene()
