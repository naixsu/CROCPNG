extends Node2D

#@export var BulletManager: PackedScene
@export var PlayerScene: PackedScene
#@onready var bullet_manager = $BulletManager

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
#	var bulletManagerInstance = BulletManager.instantiate()
#	add_child(bulletManagerInstance)
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

