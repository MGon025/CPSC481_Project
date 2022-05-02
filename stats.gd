extends Node2D
# Controls the scores of both players


onready var _p1_score = get_node("Player1Score")
onready var _p2_score = get_node("Player2Score")


func add_score(player1: bool):
	if player1:
		_p1_score.text = str(int(_p1_score.text) + 1)
	else:
		_p2_score.text = str(int(_p2_score.text) + 1)
