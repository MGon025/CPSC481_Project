extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var marks = []
var player1_is_first = false
var use_circle = true
onready var player1bg = get_node("Stats/BGLeft")
onready var player2bg = get_node("Stats/BGRight")

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in range(9):
		var path = "Marks/Mark" + str(node)
		var tile = get_node(path)
		tile.connect("mark_clicked", self, "_on_turn_end")
		marks.append(tile)
	_clear_board()

	if player1_is_first:
		player2bg.visible = false
	else:
		player1bg.visible = false
		_test_ai_click()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _clear_board():
	for mark in marks:
		mark.turn_off()


# called when a tile is clicked
func _on_turn_end():
	use_circle = !use_circle
	player1bg.visible = !player1bg.visible
	player2bg.visible = !player2bg.visible


# example of how the ai would click tile 1
func _test_ai_click():
	marks[1].toggle_mark()
