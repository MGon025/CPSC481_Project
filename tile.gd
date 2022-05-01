extends Area2D

signal mark_clicked

var enabled = true
var _selected = false
var _click_saved = false


func _ready():
	# warning-ignore:return_value_discarded
	connect("input_event", self, "_on_click")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exit")
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_mouse_enter")


func _input(event):
	# forget that a tile was selected if mouse is released outside of the tile
	if not (event is InputEventMouseButton):
		return
	if not event.is_pressed() and _click_saved:
		_click_saved = false


func turn_on(circle: bool):
	if circle:
		get_node("O").visible = true
	else:
		get_node("X").visible = true


func turn_off():
	get_node("O").visible = false
	get_node("X").visible = false


# called when a tile is left-clicked
func _on_click(_viewport, event, _shape_idx):
	if not (event is InputEventMouseButton) or\
			not enabled:
		return
	if event.is_pressed():
		_selected = true
		return
	elif _selected:
		_selected = false
		enabled = false
		turn_on(true)
		emit_signal("mark_clicked")
		print(self.name + " clicked & disabled!")


func _on_mouse_exit():
	_click_saved = true
	_selected = false


func _on_mouse_enter():
	if _click_saved:
		_selected = true
		_click_saved = false
