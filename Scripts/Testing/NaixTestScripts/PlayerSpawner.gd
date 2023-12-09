extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_player

func _spawn_player(data):
	var playerScenePath = "res://Scenes/Player/Player.tscn"
	var player = load(playerScenePath).instantiate()
	
	var playerName = data[0]
	var playerPos = data[1]
	
	player.name = playerName
	player.position = playerPos
	print(playerName)
	print(playerPos)

	return player
