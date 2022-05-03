extends Node2D
# Handles various events related to the game board.
# Events include setting up the game board, switching turns,
# and displaying the winner.


var tiles = []
var player1_turn = false
var p1_color = null
var p2_color = null
var p1_str = "O"
var p2_str = "X"
var use_circle = true
var _win_lines = []

# used to store yield state of _game_won()
var _pause = null

onready var _player1bg = get_node("Stats/BGLeft")
onready var _player2bg = get_node("Stats/BGRight")
onready var _p1_name = get_node("Stats/Names/Player1Name")
onready var _p2_name = get_node("Stats/Names/Player2Name")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Pause.hide()
	# reset marking colors
	$Tiles.modulate = Color.white
	p1_color = _player1bg.get_default_color()
	p2_color = _player2bg.get_default_color()
	_connect_signals()
	_get_tile_nodes()
	_get_win_lines()
	_clear_board()


# Called when a tile is clicked
func _on_turn_end():
	randomize()
	use_circle = !use_circle
	_player1bg.visible = !_player1bg.visible
	_player2bg.visible = !_player2bg.visible
	player1_turn = !player1_turn
	yield(_check_win(), "completed")
	_move_ai()


# Called when clicking after a game is finished.
func _on_continue(event):
	if not (event is InputEventMouseButton) or\
			event.get_button_index() != BUTTON_LEFT or\
			not event.is_pressed():
		return
	_pause.resume()


# Called after the first player is decided
func _on_game_start(player1: bool):
	# _set_tile_colors(player1)
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
	_move_ai()


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
	use_circle = true
	p1_str = "O" if player1_turn else "X"
	p2_str = "O" if not player1_turn else "X"
	_move_ai()


func _game_draw():
	$Pause/Who.text = "Draw!"
	$Pause.show()
	yield()
	$Pause.hide()
	_clear_board()
	use_circle = true
	p1_str = "O" if player1_turn else "X"
	p2_str = "O" if not player1_turn else "X"
	_move_ai()


# draws the win line according to the given beginning and end tiles
func _draw_win_line(player1: bool, begin: int, end: int):
	var win_line = null
	for line in _win_lines:
		if line.name == ("Line" + str(begin) + str(end)):
			win_line = line
	if not win_line:
		#print("win line " + str(begin) + str(end) + " does not exist")
		return
	var color = p1_color if player1\
			else p2_color
	win_line.set_default_color(color)
	win_line.show()


# store all tile nodes. called once
func _get_tile_nodes():
	for i in range(9):
		var path = "Tiles/Tile" + str(i)
		var tile = get_node(path)
		tile.connect("tile_clicked", self, "_on_turn_end")
		tiles.append(tile)


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


func _move_ai():
	if not player1_turn and not $Pause.visible:
		print("P1 = ", p1_str, "\nP2 = ", p2_str)
		var best_move = yield(find_best_move(), "completed")
		$GameStart/Timer.start(1.0)
		yield($GameStart/Timer, "timeout")
		tiles[best_move].toggle_tile()


func _check_win():
	var current_board = make_duplicate()
	if(current_board[0] == current_board[1] and current_board[1] == current_board[2] and current_board[2] != "_"):
		_pause = _game_won(!player1_turn,0,2)
	elif(current_board[3] == current_board[4] and current_board[4] == current_board[5] and current_board[5] != "_"):
		_pause = _game_won(!player1_turn,3,5)
	elif(current_board[6] == current_board[7] and current_board[7] == current_board[8] and current_board[8] != "_"):
		_pause = _game_won(!player1_turn,6,8)
	elif(current_board[0] == current_board[3] and current_board[3] == current_board[6] and current_board[6] != "_"):
		_pause = _game_won(!player1_turn,0,6)
	elif(current_board[1] == current_board[4] and current_board[4] == current_board[7] and current_board[7] != "_"):
		_pause = _game_won(!player1_turn,1,7)
	elif(current_board[2] == current_board[5] and current_board[5] == current_board[8] and current_board[8] != "_"):
		_pause = _game_won(!player1_turn,2,8)
	elif(current_board[0] == current_board[4] and current_board[4] == current_board[8] and current_board[8] != "_"):
		_pause = _game_won(!player1_turn,0,8)
	elif(current_board[2] == current_board[4] and current_board[4] == current_board[6] and current_board[6] != "_"):
		_pause = _game_won(!player1_turn,6,2)
	elif current_board.count("_") == 0:
		_pause = _game_draw()
	yield(get_tree(), "idle_frame")

func make_duplicate():
	#create a duplicate array thats easier to work with
	var duplicate = ["_","_","_","_","_","_","_","_","_"]
	for i in tiles.size():
		if tiles[i].get_node("X").visible == true:
			duplicate[i] = "X"
		elif tiles[i].get_node("O").visible == true:
			duplicate[i] = "O"
		else:
			duplicate[i] = "_"
	return duplicate

func evaluate_winner(player,board):
	#if player is "X" or "O" return true if player is winning false for no win
	if board[0] == board[1] and board[0] == board[2] and board[0] == player:
		return true
	elif(board[3] == board[4] and board[3] == board[5] and board[3] == player):
		return true
	elif(board[6] == board[7] and board[6] == board[8] and board[6] == player):
		return true
	elif(board[0] == board[3] and board[0] == board[6] and board[0] == player):
		return true
	elif(board[1] == board[4] and board[1] == board[7] and board[1] == player):
		return true
	elif(board[2] == board[5] and board[2] == board[8] and board[2] == player):
		return true
	elif(board[0] == board[4] and board[0] == board[8] and board[0] == player):
		return true
	elif(board[6] == board[4] and board[6] == board[2] and board[6] == player):
		return true
	else:
		return false
		
func is_draw(board):
	#return true is draw false otherwise
	for i in board.size():
		if board[i] == "_":
			return false
	return true
		
func minimax(board,depth,isMax):
	#get value if maximizer wins
	if evaluate_winner("X",board):
		return 10
	#get value if minimizer wins
	elif evaluate_winner("O",board):
		return -10
	#if draw no score
	elif is_draw(board):
		return 0
	
	#if maximizer
	if isMax:
		#arbitrary low score
		var best_score = -9999
		#for all empty spaces on the board
		for i in board.size():
			if board[i] == "_":
				#get value of every possible move
				board[i] = "X"
				#recursively call with more depth
				var score = minimax(board,depth+1,false)
				#reset board
				board[i] = "_"
				#return the final score that is greater
				if score > best_score:
					best_score = score
		return best_score
	#if minimizer
	else:
		#arbitrary high score
		var best_score = 9999
		#for all empty spaces on the board
		for i in board.size():
			if board[i] == "_":
				#get value of every possible move
				board[i] = "O"
				#recursively call with more depth
				var score = minimax(board,depth+1,true)
				#reset board
				board[i] = "_"
				#return the final score that is greater
				if score < best_score:
					best_score = score
		return best_score
	

func find_best_move():
	#make a easier to work with board
	var new_board = make_duplicate()
	#arbitrary score
	var best_move = -9999
	var move  = 0
	var human
	var ai
	#for all empty spaces 
	for i in new_board.size():
		if new_board[i] == "_":
			new_board[i] = "X"
			#get score
			var score  = minimax(new_board,0,false)
			#reset board
			new_board[i] = "_" 
			#if score is better return that position of the board
			if score > best_move:
				best_move = score
				move = i
	yield(get_tree(),"idle_frame")
	return move
			
		
