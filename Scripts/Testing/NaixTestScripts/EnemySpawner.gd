extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_enemy

func _spawn_enemy(data):
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_STRING:
		print("Here")
		print(data)
		return null

	var enemyType = data[1]
	var enemyScenePath = ""

	match enemyType:
		"A":
			enemyScenePath = "res://Scenes/Enemies/EnemyA/EnemyA.tscn"
		"B":
			enemyScenePath = "res://Scenes/Enemies/EnemyB/EnemyB.tscn"
		"C":
			enemyScenePath = "res://Scenes/Enemies/EnemyC/EnemyC.tscn"
		"D":
			enemyScenePath = "res://Scenes/Enemies/FinalBoss/Boss.tscn"
	var enemy = load(enemyScenePath).instantiate()
	enemy.position = data[0]

	return enemy
