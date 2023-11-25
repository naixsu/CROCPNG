extends Control

@onready var playerReadyCount = $PlayerReadyCount
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer

var readyCount : int = 0
@onready var players = GameManager.players # init player dict

# Called when the node enters the scene tree for the first time.
func _ready():
#	readyCount = players.values().count(lambda player: not player["readyState"])
	update_ready_count()
	

func update_ready_count():
	readyCount = 0
	for player in players:
		var p = players[player]
		if p["readyState"]:
			readyCount += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	
	var text = "Number of Players Ready: {0}/{1}".format({
		"0": readyCount,
		"1": players.size()
	})

	playerReadyCount.text = text


func _on_ready_button_button_down():
#	ready_up.rpc()
	ready_up()

func ready_up():
	var root = get_tree().get_root()
	print("root")
	print(self)
#	var player = root.get_node("TestMultiplayerScene/NavArea")

#
#@rpc("any_peer")
#func ready_up():
#	print("ready_up")
#	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
#		var root = get_tree().get_root()
#		print("root")
#		print(root)
