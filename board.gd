extends Node2D
# Handles various events related to the game board.
# Events include setting up the game board, switching turns,
# and displaying the winner.


var tiles = []

var player1_turn = false
var use_circle = true

var _win_lines = []
var _pause = null

onready var _player1bg = get_node("Stats/BGLeft")
onready var _player2bg = get_node("Stats/BGRight")
onready var _p1_name = get_node("Stats/Names/Player1Name")
onready var _p2_name = get_node("Stats/Names/Player2Name")
var _test_time = 0
var _test_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Pause.hide()
	# reset marking colors
	$Tiles.modulate = Color.white
	_connect_signals()
	_get_tile_nodes()
	_get_win_lines()
	_clear_board()


# Called at 60fps. delta is time between frames.
func _physics_process(delta):
	if _player2bg.visible:
		_test_ai(delta)
#	pass


# Called when a tile is clicked
func _on_turn_end():
	use_circle = !use_circle
	_player1bg.visible = !_player1bg.visible
	_player2bg.visible = !_player2bg.visible
	player1_turn = !player1_turn
	_test_win()


# Called when clicking after a game is finished.
func _on_continue(event):
	if not (event is InputEventMouseButton) or\
			event.get_button_index() != BUTTON_LEFT or\
			not event.is_pressed():
		return
	_pause.resume()


# Called after the first player is decided
func _on_game_start(player1: bool):
	_set_tile_colors(player1)
	player1_turn = player1
	if player1:
		_player1bg.show()
		_p2_name.show()
	else:
		player1_turn = false
		_player2bg.show()
		_p1_name.show()
	$Stats/Player1Score.show()
	$Stats/Player2Score.show()
	$GameStart.hide()
	_test_time = 0


func _clear_board():
	for tile in tiles:
		tile.turn_off()
	for child in $WinLines.get_children():
		child.hide()


# Call this when someone has won.
# Make sure to set _pause to _game_won() when calling this function.
func _game_won(player1: bool, begin: int, end: int):
	$Stats.add_score(player1)
	_draw_win_line(player1, begin, end)
	var text = _p1_name.text if player1 else _p2_name.text
	$Pause/Who.text = text + " Wins!"
	$Pause.show()
	yield()
	$Pause.hide()
	_clear_board()


# draws the win line according to the given beginning and end tiles
func _draw_win_line(player1: bool, begin: int, end: int):
	var win_line = null
	for line in _win_lines:
		if line.name == ("Line" + str(begin) + str(end)):
			win_line = line
	if not win_line:
		print("win line " + str(begin) + str(end) + " does not exist")
		return
	var color = _player1bg.get_default_color() if player1\
			else _player2bg.get_default_color()
	win_line.set_default_color(color)
	win_line.show()


# store all tile nodes. called once
func _get_tile_nodes():
	for i in range(9):
		var path = "Tiles/Tile" + str(i)
		var tile = get_node(path)
		tile.connect("tile_clicked", self, "_on_turn_end")
		tiles.append(tile)


# sets tile colors to BGLeft and BGRight depending on who goes first
func _set_tile_colors(player1: bool):
	# set tile colors based on player background colors
	for tile in tiles:
		tile.get_node("O").modulate = _player1bg.get_default_color() if\
				player1 else _player2bg.get_default_color()
		tile.get_node("X").modulate = _player2bg.get_default_color() if\
				player1 else _player1bg.get_default_color()


# store all win line nodes. called once
func _get_win_lines():
	for node in $WinLines.get_children():
		_win_lines.append(node)


# connects signals from other scripts/nodes to their appropriate functions
func _connect_signals():
	# warning-ignore:return_value_discarded
	$Pause/Click.connect("gui_input", self, "_on_continue")
	# warning-ignore:return_value_discarded
	$GameStart.connect("turn_decided", self, "_on_game_start")


# example of how the ai would click tile 1
func _test_ai_click():
	tiles[1].toggle_tile()
	_test_count += 1


# example of the ai making a decision after 5 seconds
func _test_ai(delta):
	_test_time += delta
	if _test_time >= 5:
		_test_ai_click()
	else:
		print("waiting... " + str(_test_time))


# example of the player winning with tiles 0,4,8
# called when switching turns after 3 enemy actions
func _test_win():
	_test_time = 0
	if _test_count == 3:
		_pause = _game_won(true, 0, 8)
		_test_count = 0
