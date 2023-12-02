extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_bomb
	

func _spawn_bomb(data):
	var bombScenePath = "res://Scenes/Bomb/Bomb.tscn"
	var bomb = load(bombScenePath).instantiate()
	var enemy = data[0]
	bomb.position = enemy.position
	bomb.isHeld = false
	
	print("Bomb spawned at " + str(bomb.position))
	
	return bomb
