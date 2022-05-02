extends Node2D
# Handles various events related to the game board.
# Events include setting up the game board, switching turns,
# and displaying the winner.


var tiles = []
var player1_turn = false
var use_circle = true
var _win_lines = []

# used to store yield state of _game_won()
var _pause = null

onready var _player1bg = get_node("Stats/BGLeft")
onready var _player2bg = get_node("Stats/BGRight")
onready var _p1_name = get_node("Stats/Names/Player1Name")
onready var _p2_name = get_node("Stats/Names/Player2Name")
# For testing. Remove or comment later
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
	# For testing. Remove or comment when AI can make their own decisions
	if _player2bg.visible and not $Pause.visible:
		_test_ai(delta)
#	pass


# Called when a tile is clicked
func _on_turn_end():
	use_circle = !use_circle
	_player1bg.visible = !_player1bg.visible
	_player2bg.visible = !_player2bg.visible
	player1_turn = !player1_turn
	# For testing. Remove or comment later
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

	# Set up Stats nodes
	if player1:
		_player1bg.show()
		_p2_name.show()
	else:
		_player2bg.show()
		_p1_name.show()
	$Stats/Player1Score.show()
	$Stats/Player2Score.show()

	# Hide start menu
	$GameStart.hide()
	# For testing. Remove or comment later
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

	# display winner's name
	var text = _p1_name.text if player1 else _p2_name.text
	$Pause/Who.text = text + " Wins!"
	$Pause.show()

	# wait for the player to click the screen
	yield()

	# reset board
	$Pause.hide()
	_clear_board()


# draws the win line according to the given beginning and end tiles
func _draw_win_line(player1: bool, begin: int, end: int):
	var win_line = null
	for line in _win_lines:
		if line.name == ("Line" + str(begin) + str(end)):
			win_line = line
	if not win_line:
		#print("win line " + str(begin) + str(end) + " does not exist")
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


# example of the ai clicking tile 1 after 5 seconds
func _test_ai(delta):
	_test_time += delta
	#var best_move = find_best_move(tiles,-1)
	var best_move = find_best_move(tiles,-1)
	if _test_time >= 1:
		tiles[best_move].toggle_tile()
		_test_count += 1
	else:
		#print("waiting... " + str(_test_time))
		pass


# example of the player winning with tiles 0,4,8
# called when switching turns after 3 enemy actions
func _test_win():
	_test_time = 0
	if _test_count == 3:
		_pause = _game_won(false, 0, 8)
		_test_count = 0
		
		
		
		
func make_duplicate(board):
	var duplicate = ["_", "_", "_","_","_","_","_","_","_"]
	for i in tiles.size():
		if tiles[i].get_node("X").visible == true:
			duplicate[i] = "X"
		elif tiles[i].get_node("O").visible == true:
			duplicate[i] = "O"
		else:
			duplicate[i] = "_"
	return duplicate
		
		
func get_empty(board):
	var empty = []
	for i in range(0,board.size()):
		if board[i] == "_":
			empty.append(i)
	return empty
	
func check_winner(board,player):
	if evaluate(board,player) != null:
		return true
	for i in board:
		if i == "_":
			return false
	return true
	
func evaluate(board,player):
	if ((board[0] == player and board[1] == player and board[2] == player) or 
	(board[3] == player and board[4] == player and board[5] == player) or
	(board[6] == player and board[7] == player and board[8] == player) or
	(board[0] == player and board[3] == player and board[6] == player) or
	(board[1] == player and board[4] == player and board[7] == player) or
	(board[2] == player and board[5] == player and board[8] == player) or
	(board[0] == player and board[4] == player and board[8] == player) or
	(board[2] == player and board[4] == player and board[6] == player)):
		return player
	else:
		return null
			
		
func minimax(board,depth,player):
	var empty = get_empty(board)
	if depth == 0 or check_winner(board,player):
		if evaluate(board,player) == "O":
			return 0
		elif evaluate(board,player) == "X":
			return 100
		else:
			return 50
	elif player == "X":
		var best_val = 0
		for i in empty:
			board[i] = player
			var move_val = minimax(board,depth-1,"O")
			board[i] = "_"
			best_val = max(best_val,move_val)
		return best_val
	elif player == "O":
		var best_val = 100
		for i in empty:
			board[i] = player
			var move_val = minimax(board,depth-1,"X")
			board[i] = "_"
			best_val = min(best_val,move_val)
		return best_val

func find_best_move(board,depth):
	var new_board = make_duplicate(board)
	var best_val = 40
	var board_choice = []
	var available = get_empty(new_board)
	var player = "X"
	for move in available:
		new_board[move] = player
		var move_val = minimax(new_board,depth-1,"O")
		new_board[move] = "_"
		if move_val > best_val:
			board_choice = [move]
			break
		elif move_val == best_val:
			board_choice.append(move)
	if board_choice.size() > 0:
		var random:int = randi() % board_choice.size()
		return board_choice[random]
	else:
		var random:int = randi() % available.size()
		return available[random]
		
