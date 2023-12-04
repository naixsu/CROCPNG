extends Node2D

#@export var BulletManager: PackedScene
@export var PlayerScene: PackedScene
@export var EnemyA: PackedScene
#@onready var bullet_manager = $BulletManager
var spawn_points = []

@onready var readyPrompt = $ReadyPrompt
@export var waveResources : Array[Resource]
@onready var endBanner = $EndBanner

# Called when the node enters the scene tree for the first time.
func _ready():
	readyPrompt.connect("start_wave", start_wave)
	readyPrompt.connect("reward_players", reward_players) # Give money after beating a round
	readyPrompt.connect("win_banner", win_banner)
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
#		currentPlayer.name = str(GameManager.players[i].name)
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

#func _unhandled_input(event):
#	if event.is_action_pressed("Spawn"):
##		spawn_enemy.rpc()
#		spawn_enemy()
#		pass


# Might wanna use a resource here so that the wave feature
# so that waves aren't randomized
func spawn_enemy(enemyType: String):
	var randomIndex : int
	var randomSpawnPoint : Vector2
	if enemyType == "D":
		randomIndex = 26 # hard coded
		randomSpawnPoint = spawn_points[randomIndex].position
	else:
		
		randomIndex = randi_range(0, spawn_points.size() - 1)
		randomSpawnPoint = spawn_points[randomIndex].position
#	var enemy_types = ["A", "B", "C"]
#	var random_enemy_type = enemy_types[randi_range(0, enemy_types.size() - 1)]
#		print("spawn: " + str(random_spawn_point) + " type: " + str(random_enemy_type))
#	if is_multiplayer_authority():
#		get_node("EnemySpawner").spawn([random_spawn_point, random_enemy_type])
	get_node("EnemySpawner").spawn([randomSpawnPoint, enemyType])
	add_enemy.rpc()

func spawn_bomb(enemyPos):
	clear_bombs()
	get_node("BombSpawner").spawn([enemyPos])
	print("Spawn Bomb")

func clear_bombs():
	if multiplayer.is_server():
		var bombGroups = get_node("BombGroups")
		if bombGroups.get_children().size() == 0: return
		
		var child = bombGroups.get_child(0)
		
		if child != null:
			child.queue_free()
			print("Cleared bomb")
			
@rpc("any_peer", "call_local")
func find_to_hold_bomb():
	await get_tree().create_timer(0.1).timeout
	var enemyGroups = get_node("EnemyGroups")
	var children = enemyGroups.get_children()
	if children != null:
		for child in children:
			if not child.hasBomb and not child.dead:
				child.hasBomb = true
				print("Next bomb holder is " + str(child.name))
				break


@rpc("any_peer", "call_local")
func lose():
	print("You lost")

func start_wave():
#	if is_multiplayer_authority():
	if multiplayer.is_server():
		clear_money.rpc()
		add_wave.rpc()
		
#		if GameManager.wave == GameManager.maxWave: # Stopping at 5 for now
#			final_wave()

		if GameManager.wave == 1:
#			final_wave()
			final_wave.rpc()
			
			
			
		print("Starting Wave %d of %d" % [GameManager.wave, GameManager.maxWave])
		var spawnDelay = 0.3
		var enemyGroups = get_node("EnemyGroups")
		var waveData = waveResources[GameManager.wave-1]
		print("WAVE DATA")
		var skeletonCount = waveData.SkeletonCount
		var ghostCount = waveData.GhostCount
		var slimeCount = waveData.SlimeCount
		var enemyArray = {
			"A": skeletonCount,
			"B": ghostCount,
			"C": slimeCount
		}
		var totalEnemies = skeletonCount + ghostCount + slimeCount
		print("Wave %d: Number of Enemies: %d" % [GameManager.wave, totalEnemies])
		
		# Spawn bomb once
		var bombSpawned = false
		
		if GameManager.finalWave:
			await get_tree().create_timer(spawnDelay).timeout
			spawn_enemy("D")
			await get_tree().create_timer(0.1).timeout
			if not bombSpawned:
				var child = enemyGroups.get_child(0) # get first child, first enemy
#					spawn_bomb(child.position)
				child.hasBomb = true
				bombSpawned = true
		
		for enemyType in enemyArray:
			var count = enemyArray[enemyType]
			for enemy in range(count):
				await get_tree().create_timer(spawnDelay).timeout
				spawn_enemy(enemyType)
				
				await get_tree().create_timer(0.1).timeout
				if not bombSpawned:
					var child = enemyGroups.get_child(0) # get first child, first enemy
#					spawn_bomb(child.position)
					child.hasBomb = true
					bombSpawned = true
					

func reward_players():
	print("Reward Players")
	var players = get_tree().get_nodes_in_group("Player")
	var rewardMoney = 150 * GameManager.wave
	
	for player in players:
		player.set_money(rewardMoney)

					
@rpc("any_peer", "call_local")
func clear_money():
	print("Clearing Money")
	var moneyGroups = get_node("MoneyGroups")
	var children = moneyGroups.get_children()
	
	for child in children:
		child.queue_free()
	
@rpc("any_peer", "call_local")
func add_wave():
	GameManager.wave += 1
		
@rpc("any_peer", "call_local")
func add_enemy():
	GameManager.enemyCount += 1	
		
@rpc("any_peer", "call_local")
func final_wave():
	GameManager.finalWave = true
	print("Final Wave")

func win_banner():
	endBanner.visible = true
	endBanner.get_node("Banners").get_node("WinBanner").visible = true

