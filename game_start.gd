extends Node2D

signal turn_decided(player_is_first)

onready var p1_color = get_node("../Stats/BGLeft").get_default_color()
onready var p2_color = get_node("../Stats/BGRight").get_default_color()
onready var p1_name = get_node("../Stats/Names/Player1Name")
onready var p2_name = get_node("../Stats/Names/Player2Name")


# Called when the node enters the scene tree for the first time.
func _ready():
	p1_name.hide()
	p2_name.hide()

	$Timer.start(3.0)
	yield($Timer, "timeout")
	_on_timer_ended()


func _on_timer_ended():
	print("e")
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var player_is_first = rng.randi_range(0, 1)

	if player_is_first:
		p1_name.show()
		$FirstColor.set_frame_color(p1_color)
	else:
		p2_name.show()
		self.set_position(Vector2(1024, 600))
		self.set_rotation(PI)
		$FirstColor.set_frame_color(p2_color)

	$Timer.start(1.5)
	yield($Timer, "timeout")

	$AnimationPlayer.play("swipe_left")
	yield($AnimationPlayer, "animation_finished")

	emit_signal("turn_decided", player_is_first)
