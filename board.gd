extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tiles = []
var player1_is_first = true
var use_circle = true
onready var player1bg = get_node("Stats/BGLeft")
onready var player2bg = get_node("Stats/BGRight")

# Called when the node enters the scene tree for the first time.
func _ready():
	# reset marking colors
	$Tiles.modulate = Color.white

	_get_tile_nodes()
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
	for tile in tiles:
		tile.turn_off()


# store all tile nodes
func _get_tile_nodes():
	for i in range(9):
		var path = "Tiles/Tile" + str(i)
		var tile = get_node(path)

		# set tile colors based on player background colors
		tile.get_node("O").modulate = player1bg.get_default_color() if\
				player1_is_first else player2bg.get_default_color()
		tile.get_node("X").modulate = player2bg.get_default_color() if\
				player1_is_first else player1bg.get_default_color()

		tile.connect("tile_clicked", self, "_on_turn_end")
		tiles.append(tile)


# called when a tile is clicked
func _on_turn_end():
	use_circle = !use_circle
	player1bg.visible = !player1bg.visible
	player2bg.visible = !player2bg.visible


# example of how the ai would click tile 1
func _test_ai_click():
	tiles[1].toggle_tile()
