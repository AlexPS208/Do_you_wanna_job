extends CanvasLayer

@onready var menu: Control = $Menu
@onready var menu_panel: ColorRect = $Menu/MenuPanel
@onready var exit_pre_confirm_panel: ColorRect = $Menu/Exit_pre_confirm
@onready var exit_confirm_panel: ColorRect = $Menu/Exit_confirm
@onready var button_sound: AudioStreamPlayer3D = $Button_sound

var is_menu_active: bool = false
var is_menu_panel_active: bool = false
var is_pre_confirm_active: bool = false
var is_confirm_active: bool = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		button_sound.play()
		if !is_menu_active:
			show_menu()
		else:
			hide_menu()

func show_menu() -> void:
	get_tree().paused = true
	
	menu_panel.visible = true
	is_menu_active = true
	is_menu_panel_active = true
	
	exit_pre_confirm_panel.visible = false
	is_pre_confirm_active = false


func hide_menu() -> void:
	get_tree().paused = false
	
	menu_panel.visible = false
	exit_pre_confirm_panel.visible = false
	exit_confirm_panel.visible = false
	
	is_menu_active = false
	is_pre_confirm_active = false
	is_confirm_active = false


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
