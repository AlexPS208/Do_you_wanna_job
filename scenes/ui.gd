extends CanvasLayer

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
@onready var question_counter: Label = $Timebar/Question_counter


var is_menu_active: bool = false
var is_menu_panel_active: bool = false
var is_pre_confirm_active: bool = false
var is_confirm_active: bool = false

var dialog_node
var current_skip_choice: int = 0

var original_timebar_width: float
var original_timebar_position: Vector2

var original_fov: float = 70.0
var target_fov: float = 60.0
var original_sight_color: Color = Color(1, 1, 1, 0)  # ffffff00
var target_sight_color: Color = Color(1, 1, 1, 1)    # ffffff
var lerp_speed: float = 0.3

var questions_value = 11

var main_labels = ["main_01", "main_02"]
var event_labels = {
	"group_1": ["event_01_01", "event_01_02"],
	"group_2": ["event_02_01", "event_02_02", "event_02_03"]
}
var used_labels = []


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	dialog_node = Dialogic.start("First_manager")
	
	original_timebar_width = timebar_bar.size.x
	original_timebar_position = timebar_bar.position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		button_sound.play()
		if !is_menu_active:
			show_menu()
		else:
			hide_menu()
	
	if !timer.is_stopped():
		var remaining_time = timer.time_left
		var total_time = timer.wait_time
		update_timebar(total_time, remaining_time)
		# Плавное изменение FOV камеры
		camera.fov = lerp(camera.fov, target_fov, lerp_speed * delta)
		# Плавное изменение modulate у sight
		sight.modulate = sight.modulate.lerp(target_sight_color, lerp_speed * delta)
	else:
		# Возврат к исходным значениям
		camera.fov = lerp(camera.fov, original_fov, lerp_speed * delta * 15)
		sight.modulate = sight.modulate.lerp(original_sight_color, lerp_speed * delta * 15)


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
	
	toggle_dialogic_layer(true)


func hide_menu() -> void:
	get_tree().paused = false
	
	menu_panel.visible = false
	exit_pre_confirm_panel.visible = false
	exit_confirm_panel.visible = false
	
	is_menu_active = false
	is_pre_confirm_active = false
	is_confirm_active = false
	
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
	if argument.has("start_timer"):
		var duration = argument["start_timer"]
		current_skip_choice = argument["skip_choice"]
		start_timer(duration)
	if argument.has("stop_timer"):
		stop_timer()
		if argument["is_answered"]:
			decrease_questions_value()

	if argument.has("random_question"):
		random_jump()


# RANDOM QUESTION
func random_jump(is_event: bool = false, event_group: String = ""):
	if questions_value <= 0:
		Dialogic.Jump.jump_to_label("End")
		return
	
	var available_labels = []
	
	if is_event and event_group in event_labels:
		for label in event_labels[event_group]:
			if not used_labels.has(label):
				available_labels.append(label)
	else:
		for label in main_labels:
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


# TIMER AND TIMEBAR
func start_timer(duration: float) -> void:
	timebar_bar.size.x = original_timebar_width
	timebar_bar.position.x = original_timebar_position.x

	timer.wait_time = duration
	timer.start()

func _on_timer_timeout() -> void:
	focus_on_skip_choice()
	get_viewport().gui_get_focus_owner().pressed.emit()
	stop_timer()

func stop_timer() -> void:
	if !timer.is_stopped():
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
