extends Node2D
# Handles choosing which player goes first.
# The choice is decided after 3 seconds, then a short animation plays before
# beginning the game.


signal turn_decided(player_is_first)

onready var _p1_color = get_node("../Stats/BGLeft").get_default_color()
onready var _p2_color = get_node("../Stats/BGRight").get_default_color()
onready var _p1_name = get_node("../Stats/Names/Player1Name")
onready var _p2_name = get_node("../Stats/Names/Player2Name")


# Called when the node enters the scene tree for the first time.
func _ready():
	_p1_name.hide()
	_p2_name.hide()
	$Timer.start(4.0)
	_start_dots()
	yield($Timer, "timeout")
	_decide()


func _start_dots():
	$Dots.text = ""
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_one_shot(false)
	timer.start(1.0)


func _on_timer_timeout():
	if len($Dots.text) < 3:
		$Dots.text += "."


func _decide():
	$Dots.hide()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var player_is_first = rng.randi_range(0, 1)

	if player_is_first:
		_p1_name.show()
		$FirstColor.set_frame_color(_p1_color)
	else:
		_p2_name.show()
		self.set_position(Vector2(1024, 600))
		self.set_rotation(PI)
		$FirstColor.set_frame_color(_p2_color)

	$Timer.start(1.5)
	yield($Timer, "timeout")

	$AnimationPlayer.play("swipe_left")
	yield($AnimationPlayer, "animation_finished")

	emit_signal("turn_decided", player_is_first)
