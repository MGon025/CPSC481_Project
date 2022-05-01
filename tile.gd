extends Area2D

signal mark_clicked

var enabled = true


func _ready():
	if not is_connected("input_event", self, "_on_click"):
		# warning-ignore:return_value_discarded
		connect("input_event", self, "_on_click")


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
			not event.is_pressed() or\
			not enabled:
		return
	enabled = false
	emit_signal("mark_clicked")
	print(self.name + " clicked & disabled!")
