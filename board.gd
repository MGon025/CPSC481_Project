extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var marks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in range(9):
		var path = "Marks/Mark" + str(node)
		marks.append(get_node(path))
	_clear_board()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _clear_board():
	for mark in marks:
		mark.get_node("X").visible = false
		mark.get_node("O").visible = false

