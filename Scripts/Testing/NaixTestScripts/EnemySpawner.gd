extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_enemy

func _spawn_enemy(data):
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_STRING:
		print("Here")
		print(data)
		return null
#	var bomb = preload("res://bomb.tscn").instantiate()
	var enemyType = data[1]
#	var enemy = null
	var enemyScenePath = ""
#	if enemy_type == "A": enemy = preload("res://Scenes/Enemies/EnemyA/EnemyA.tscn").instantiate()
#	elif enemy_type == "B": enemy = preload("res://Scenes/Enemies/EnemyB/EnemyB.tscn").instantiate()
#	elif enemy_type == "C": enemy = preload("res://Scenes/Enemies/EnemyC/EnemyC.tscn").instantiate()
	match enemyType:
		"A":
			enemyScenePath = "res://Scenes/Enemies/EnemyA/EnemyA.tscn"
		"B":
			enemyScenePath = "res://Scenes/Enemies/EnemyB/EnemyB.tscn"
		"C":
			enemyScenePath = "res://Scenes/Enemies/EnemyC/EnemyC.tscn"
	var enemy = load(enemyScenePath).instantiate()
	enemy.position = data[0]
		
	print("Enemey " + enemyType + " spawned at " + str(enemy.position))

	return enemy
