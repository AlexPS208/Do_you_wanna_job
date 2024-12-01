extends Control

@onready var canvas: CanvasLayer = $CanvasLayer

func _hide_slider():
	canvas.visible = false

func _show_slider():
	canvas.visible = true


func _on_h_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
