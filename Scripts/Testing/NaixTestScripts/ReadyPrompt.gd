extends CanvasLayer

@onready var playerReadyCount = $PlayerReadyCount
#@onready var players = GameManager.players # init player dict

var readyCount : int = 0

signal toggle_ready
signal update_ready

# Called when the node enters the scene tree for the first time.
func _ready():
#	readyCount = players.values().count(lambda player: not player["readyState"])
#	update_ready_count.rpc()
	update_ready_count()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	
	var text = "Number of Players Ready: {0}/{1}".format({
		"0": readyCount,
		"1": GameManager.players.size()
	})

	playerReadyCount.text = text


func _on_ready_button_button_down():
#	ready_up.rpc()
	ready_up()

#@rpc("any_peer")
func update_ready_count():
#	update_ready_count_rpc.rpc()
	print("Test " + str(multiplayer.get_unique_id()))
	
#	print("Updating ready count")
#	readyCount = 0
#	for player in players:
#		var p = players[player]
#		if p["readyState"]:
#			readyCount += 1

@rpc("any_peer")
func update_ready_count_rpc():
	print("Updating ready count RPC")
	readyCount = 0
	var players = GameManager.players
	for player in players:
		var p = players[player]
		if p["readyState"]:
			readyCount += 1

#	var players = get_tree().get_nodes_in_group("Player")
#
#	print(players)
#	for player in players:
#		var readyState = player.readyState
#		if readyState: readyCount += 1
#	print()
#	print(readyCount)
#	print()

func ready_up():
	var root = get_tree().get_root()
	print("root")
	print(self)
	toggle_ready.emit()
#	var player = root.get_node("TestMultiplayerScene/NavArea")

#
#@rpc("any_peer")
#func ready_up():
#	print("ready_up")
#	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
#		var root = get_tree().get_root()
#		print("root")
#		print(root)


#func _on_player_update_ready_state():
#	update_ready_count()
