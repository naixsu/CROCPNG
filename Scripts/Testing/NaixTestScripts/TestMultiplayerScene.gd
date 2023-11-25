extends Node2D

#@export var BulletManager: PackedScene
@export var PlayerScene: PackedScene
@export var EnemyA: PackedScene
#@onready var bullet_manager = $BulletManager
var spawn_points = []

@onready var readyPrompt = $ReadyPrompt

# Called when the node enters the scene tree for the first time.
func _ready():
	readyPrompt.connect("start_wave", start_wave)
	var index = 0
#	var bulletManagerInstance = BulletManager.instantiate()
#	add_child(bulletManagerInstance)
	var spawn_point_parent = get_node("EnemySpawnPoints")
	var children = spawn_point_parent.get_children()
	for child in children:
		if child is Marker2D:
			spawn_points.append(child)
	
	for i in GameManager.players:
		var currentPlayer = PlayerScene.instantiate()
		

		currentPlayer.name = str(GameManager.players[i].id)
#		currentPlayer.connect("player_fired_bullet", bullet_manager.handle_bullet_spawned)
#		currentPlayer.connect("player_fired_bullet", BulletManager.handle_bullet_spawned)
#		currentPlayer.connect("player_fired_bullet", bulletManagerInstance.handle_bullet_spawned)
		add_child(currentPlayer)
#		add_child(bulletManagerInstance)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1
				
	# playerScene.connect("player_fired_bullet", bullet_manager.handle_bullet_spawned)

func _unhandled_input(event):
	if event.is_action_pressed("Spawn"):
#		spawn_enemy.rpc()
		spawn_enemy()
		pass

func spawn_enemy():
	var random_index = randi_range(0, spawn_points.size() - 1)
	var random_spawn_point = spawn_points[random_index].position
	var enemy_types = ["A", "B", "C"]
	var random_enemy_type = enemy_types[randi_range(0, enemy_types.size() - 1)]
#		print("spawn: " + str(random_spawn_point) + " type: " + str(random_enemy_type))
	get_node("EnemySpawner").spawn([random_spawn_point, random_enemy_type])
			
	
#@rpc("any_peer", "call_local")
#func spawn_enemy():
#	# Get random spawn point
#	print("Spawn Enemy")
#	var enemySpawnPoints = get_tree().get_nodes_in_group("EnemySpawnPoint")
#	var randomIndex = randi_range(0, enemySpawnPoints.size() - 1)
#	var randomSpawnPoint = enemySpawnPoints[randomIndex]
#
#	# Instantiate enemy
#	var enemy = EnemyA.instantiate()
#	add_child(enemy)
#	enemy.global_position = randomSpawnPoint.global_position

func start_wave():
	GameManager.wave += 1
	print("Starting Wave %d of %d" % [GameManager.wave, GameManager.maxWave])
	
	var enemyGroups = get_node("EnemyGroups")
	if GameManager.wave == 1:
		print("Wave 1")
		for i in range(20):
			spawn_enemy()
	

