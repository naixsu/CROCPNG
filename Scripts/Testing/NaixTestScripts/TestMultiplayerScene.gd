extends Node2D

#@export var BulletManager: PackedScene
@export var PlayerScene: PackedScene
@export var EnemyA: PackedScene
#@onready var bullet_manager = $BulletManager

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
#	var bulletManagerInstance = BulletManager.instantiate()
#	add_child(bulletManagerInstance)
	for i in GameManager.players:
		var currentPlayer = PlayerScene.instantiate()
		
#		var camera = Camera2D.new()
#		currentPlayer.add_child(camera)
#		camera.make_current()
		
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
		spawn_enemy.rpc()

@rpc("any_peer", "call_local")
func spawn_enemy():
	# Get random spawn point
	print("Spawn Enemy")
	var enemySpawnPoints = get_tree().get_nodes_in_group("EnemySpawnPoint")
	var randomIndex = randi_range(0, enemySpawnPoints.size() - 1)
	var randomSpawnPoint = enemySpawnPoints[randomIndex]
	
	# Instantiate enemy
	var enemy = EnemyA.instantiate()
	add_child(enemy)
	enemy.global_position = randomSpawnPoint.global_position
	

