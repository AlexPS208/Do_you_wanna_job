extends Node

var standart_cursor = load("res://assets/cursor.png")
var clicked_cursor = load("res://assets/cursor_click.png")


func _ready():
	Input.set_custom_mouse_cursor(standart_cursor)
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				Input.set_custom_mouse_cursor(clicked_cursor)
			else:
				Input.set_custom_mouse_cursor(standart_cursor)
