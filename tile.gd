extends Area2D
# Handles how the tiles are used.
# A user can left-click to use a tile. The tile will only be used upon
# releasing the mouse button on the same tile that the button was pressed on.
# toggle_tile() is also available for AIs to simulate clicking.


signal tile_clicked

var enabled = true
var _selected = false
var _click_saved = false
onready var _board = get_node("../..")


func _ready():
	# warning-ignore:return_value_discarded
	connect("input_event", self, "_on_click")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exit")
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_mouse_enter")


func _input(event):
	# forget that a tile was selected if mouse is clicked outside of the tile
	if not (event is InputEventMouseButton) or\
			 event.get_button_index() != BUTTON_LEFT:
		return
	if _click_saved:
		_click_saved = false


func toggle_tile():
	enabled = false
	_turn_on(_board.use_circle)
	emit_signal("tile_clicked")
	print(self.name + " clicked & disabled!")


func turn_off():
	get_node("O").visible = false
	get_node("X").visible = false
	enabled = true


func _turn_on(circle: bool):
	var color = _board.p1_color if _board.player1_turn else _board.p2_color
	if circle:
		$O.modulate = color
		get_node("O").visible = true
	else:
		$X.modulate = color
		get_node("X").visible = true


# called when a tile is left-clicked
func _on_click(_viewport, event, _shape_idx):
	if not (event is InputEventMouseButton) or\
			event.get_button_index() != BUTTON_LEFT or\
			not _board.player1_turn or\
			not enabled:
		return
	if event.is_pressed():
		_selected = true
		return
	elif _selected:
		_selected = false
		toggle_tile()


func _on_mouse_exit():
	_click_saved = true
	_selected = false


func _on_mouse_enter():
	if _click_saved:
		_selected = true
		_click_saved = false
