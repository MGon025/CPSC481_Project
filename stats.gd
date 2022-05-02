extends Node2D

onready var p1_score = get_node("Player1Score")
onready var p2_score = get_node("Player2Score")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func add_score(player1: bool):
	if player1:
		p1_score.text = str(int(p1_score.text) + 1)
	else:
		p2_score.text = str(int(p2_score.text) + 1)
