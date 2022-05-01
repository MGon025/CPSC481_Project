extends Area2D

signal turn_ended

var enabled = true


func _ready():
	if not is_connected("input_event", self, "_on_click"):
		# warning-ignore:return_value_discarded
		connect("input_event", self, "_on_click")


func _on_click(_viewport, event, _shape_idx):
	if not enabled:
		return
	if (event is InputEventMouseButton) && event.is_pressed():
		enabled = false
		emit_signal("turn_ended")
		print(get_node("..").name + " clicked & disabled!")
