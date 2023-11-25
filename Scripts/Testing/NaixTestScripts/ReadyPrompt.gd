extends CanvasLayer

@onready var playerReadyCount = $PlayerReadyCount
#@onready var players = GameManager.players # init player dict

@export var readyCount : int = 0

signal toggle_ready

func _on_ready_button_button_down():
#	ready_up.rpc()
	ready_up()

func _process(delta):
	update_ready_count()
	
	
#@rpc("any_peer")
func update_ready_count():
	readyCount = 0
	# Get all players in the tree
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		if player.readyState == true: 
			readyCount += 1
#	var players = GameManager.players
#	for player in players:
#		if players[player].readyState: readyCount += 1
	
	var text = "Number of Players Ready: {0}/{1}".format({
		"0": str(readyCount),
		"1": GameManager.players.size()
	})

	playerReadyCount.text = text
	

func ready_up():
	toggle_ready.emit()
