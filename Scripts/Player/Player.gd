extends CharacterBody2D

class_name Player
###
# Grouped to: Player
###

# Export vars here
@export var speed = 300
@export var maxSpeed = speed
@export var dashSpeed = 800
@export var dashLength = 0.3
@export var health = 100
@export var maxHealth = health
@export var Bullet : PackedScene
@export var Enemy : PackedScene
@export var BulletCB : PackedScene

# Onready vars here
@onready var anim = $AnimatedSprite2D
#@onready var gunRotation = $GunRotation
#@onready var fireCooldown = $GunRotation/FireCooldown
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer
@onready var weaponsManager = $WeaponsManager
@onready var dash = $Dash

# Camera Onready Vars TO BE DEBUGGED
@onready var playerCamera = $Camera2D

@onready var readyPrompt = get_tree().get_root().get_node("TestMultiplayerScene/ReadyPrompt")
@onready var readyLabel = $ReadyLabel
@onready var respawnNode = $Respawn # Avoiding variable names (resoawn)
@onready var respawnLabel = $Respawn/RespawnLabel
@onready var respawnTimer = $Respawn/RespawnTimer
@onready var moneyLabel = $MoneyLabel
@onready var shop = $Shop
@onready var nameLabel = $NameLabel
@onready var healthLabel = $HealthLabel

@onready var weaponFile = "res://Scenes/Player/WeaponData.json"
@onready var iFramesTimer = $IFramesTimer
@onready var collision = $CollisionShape2D
@onready var SoundManager = $SoundManager # Capitalizing this

@onready var meleeNode = $WeaponsManager/Melee
@onready var HUD = $HUD


# Signals here
signal update_ready
signal upgrade(stat)


# Other global vars here
@export var dead = false
var spawn_points = []
var tempSpeed = maxSpeed
@export var readyState = false # had to avoid 'ready' builtin keyword
@export var canDash = false

var weapons
var weaponsData: Array = []
@export var currentWeaponIndex = 0
@export var weapon_held_down = false
var currentWeapon

@export var respawn = false
@export var displayRespawn = false
@export var money : int = 300
@export var weaponMods = {
	"pistol": {
		"damage": 0,
		"accuracy": 0,
		"bulletSpeed": 0,
		"dUp": 1.25,
		"aUp": 2,
		"bsUp": 62.5
	},
	"rifle": {
		"damage": 0,
		"accuracy": 0,
		"bulletSpeed": 0,
		"dUp": 2.5,
		"aUp": 1.25,
		"bsUp": 75
	},
	"shotgun": {
		"damage": 0,
		"accuracy": 0,
		"bulletSpeed": 0,
		"dUp": 2.5,
		"aUp": 7.5,
		"bsUp": 200
	}
}

@export var dmgAdd : float
@export var accSub : float
@export var bulletSpeedAdd : float


# Shop stuff
var playerShop
var playerAnim2D
var healthProgressBar
var speedProgressBar
var dashProgressBar
var hb
var sb
var db

var pistolShop
var pistolDmgProgressBar
var pistolAccProgressBar
var pistolBSProgressBar
var pdb # damage button
var pab # acc button
var pbb # bulletspeed button

var rifleShop
var rifleDmgProgressBar
var rifleAccProgressBar
var rifleBSProgressBar
var rdb
var rab
var rbb

var shotgunShop
var shotgunDmgProgressBar
var shotgunAccProgressBar
var shotgunBSProgressBar
var sdb
var sab
var sbb

var meleeShop
var meleeDmgProgressBar
var mdb

var shopMoneyLabel

var shopButtons = []
var shopPrices = []
var weaponUpgrades : Dictionary
# multiplayer syncing
#var syncPos = Vector2(0, 0)
#var syncRot = 0

func _ready():
	init_weapons(weaponFile)
	init_shop()
	
	readyPrompt.connect("toggle_ready", toggle_ready)
	shop.connect("upgrade", player_upgrade)
	meleeNode.connect("finished_anim", finished_anim)

	multiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	# Set the camera and hud
	# to only be active for the local player
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
#		add_child(HUD.instantiate())
		playerCamera.make_current()
		HUD.visible = true
		update_hud.rpc()
	anim.play("idle")
	
#	print(GameManager.players[str(name)])
	
	
	nameLabel.text = str(GameManager.players[name.to_int()].name)
	
	
		

func _process(delta):
	if GameManager.gameOver: return 
	readyLabel.text = str(readyState)
	moneyLabel.text = str(money)
	healthLabel.text = str(health)
#	update_hud()
	
	if respawn:
		respawnTimer.start()
		respawnLabel.show()
		displayRespawn = true
	
	if displayRespawn: 
		display_respawn()

func _physics_process(delta):
	if GameManager.gameOver: return 
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var direction = Input.get_vector("Left", "Right", "Up", "Down")
#		speed = dashSpeed if dash.is_dashing() else tempSpeed
#		velocity = direction * speed
		if dash.is_dashing():
			velocity = direction * dashSpeed
		else:
			velocity = direction * speed
		
#		syncPos = global_position
#		syncRot = rotation_degrees

		# Play the death animation
		# TODO:
		# Remove this later when adding the actual death feature
#		if Input.is_action_just_pressed("ui_accept"):
#			die.rpc()

		if Input.is_action_just_pressed("Dash") and canDash:
			var mouse_direction = get_local_mouse_position().normalized()
			velocity = Vector2(dashSpeed * mouse_direction.x, dashSpeed * mouse_direction.y)
			dash.start_dash(dashLength)
			
		if not dead:
			update_gun_rotation()
#			move_and_slide()
			move_and_collide(velocity * delta)
			update_animation()
			check_hit()

	update_camera(delta)
	
# Commenting as it has synchronization issues
func _unhandled_input(event): 
	if GameManager.gameOver: return 
	# TODO:
	# Handle Weapon stuff in a separate node for reusability
	# using signals to fire off from Weapon -> Player -> BulletManager
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id() and not dead:
		if event.is_action_pressed("Fire"):
			fire.rpc(true)
			
		if event.is_action_released("Fire"):
			fire.rpc(false)
			
		if event.is_action_pressed("SwitchWeapon1") and currentWeaponIndex != 0:
#			currentWeaponIndex = 0
			switch_weapon.rpc(0)
		if event.is_action_pressed("SwitchWeapon2") and currentWeaponIndex != 1:
#			currentWeaponIndex = 1
			switch_weapon.rpc(1)
		if event.is_action_pressed("SwitchWeapon3") and currentWeaponIndex != 2:
#			currentWeaponIndex = 2
			switch_weapon.rpc(2)
		if event.is_action_pressed("SwitchWeapon4") and currentWeaponIndex != 3:
			switch_weapon.rpc(3)
		
		update_hud.rpc()
	pass

func init_weapons(weaponFile):
	var f = FileAccess.open(weaponFile, FileAccess.READ)
	var content = f.get_as_text()
	weaponsData = JSON.parse_string(content)	
	
#	weapons = weaponsManager.get_children()
#	currentWeapon = weapons[currentWeaponIndex]
	weapons = weaponsManager.get_child(0)
	currentWeapon = weapons
	currentWeapon.get_node("FireCooldown").wait_time = weaponsData[currentWeaponIndex].wait_time

func init_shop():
	print("Initializing shop")
	playerShop = shop.get_node("TabContainer").get_node("Player")
	playerAnim2D = playerShop.get_node("Panel").get_node("Player")
	playerAnim2D = self.anim
	healthProgressBar = playerShop.get_node("Health").get_node("ProgressBar")
	speedProgressBar = playerShop.get_node("Speed").get_node("ProgressBar")
	dashProgressBar = playerShop.get_node("Dash").get_node("ProgressBar")
	hb = playerShop.get_node("Health").get_node("HealthButton")
	sb = playerShop.get_node("Speed").get_node("SpeedButton")
	db = playerShop.get_node("Dash").get_node("DashButton")
	
	pistolShop = shop.get_node("TabContainer").get_node("Pistol")
	pistolDmgProgressBar = pistolShop.get_node("Damage").get_node("ProgressBar")
	pistolAccProgressBar = pistolShop.get_node("Accuracy").get_node("ProgressBar")
	pistolBSProgressBar = pistolShop.get_node("Bulletspeed").get_node("ProgressBar")
	pdb = pistolShop.get_node("Damage").get_node("PDmgButton")
	pab = pistolShop.get_node("Accuracy").get_node("PAccButton")
	pbb = pistolShop.get_node("Bulletspeed").get_node("PBSButton")
	
	rifleShop = shop.get_node("TabContainer").get_node("Rifle")
	rifleDmgProgressBar = rifleShop.get_node("Damage").get_node("ProgressBar")
	rifleAccProgressBar = rifleShop.get_node("Accuracy").get_node("ProgressBar")
	rifleBSProgressBar = rifleShop.get_node("Bulletspeed").get_node("ProgressBar")
	rdb = rifleShop.get_node("Damage").get_node("RDmgButton")
	rab = rifleShop.get_node("Accuracy").get_node("RAccButton")
	rbb = rifleShop.get_node("Bulletspeed").get_node("RBSButton")
	
	shotgunShop = shop.get_node("TabContainer").get_node("Shotgun")
	shotgunDmgProgressBar = shotgunShop.get_node("Damage").get_node("ProgressBar")
	shotgunAccProgressBar = shotgunShop.get_node("Accuracy").get_node("ProgressBar")
	shotgunBSProgressBar = shotgunShop.get_node("Bulletspeed").get_node("ProgressBar")
	sdb = shotgunShop.get_node("Damage").get_node("SDmgButton")
	sab = shotgunShop.get_node("Accuracy").get_node("SAccButton")
	sbb = shotgunShop.get_node("Bulletspeed").get_node("SBSButton")
	
	meleeShop = shop.get_node("TabContainer").get_node("Melee")
	meleeDmgProgressBar = meleeShop.get_node("Damage").get_node("ProgressBar")
	mdb = meleeShop.get_node("Damage").get_node("MDmgButton")
	
	shopMoneyLabel = shop.get_node("Money").get_node("MoneyLabel")
	
	# HARDCODED
	# THESE HAVE TO BE IN ORDER
	shopButtons = [	hb, sb, db,
					pdb, pab, pbb,
					rdb, rab, rbb,
					sdb, sab, sbb,
					]

	shopPrices = [	shop.playerHealthCost, shop.playerSpeedCost, shop.playerDashCost,
					shop.pistolDmgCost, shop.pistolAccCost, shop.pistolBSCost,
					shop.rifleDmgCost, shop.rifleAccCost, shop.rifleBSCost,
					shop.shotgunDmgCost, shop.shotgunAccCost, shop.shotgunBSCost,
					shop.meleeDmgCost
					]
	
	weaponUpgrades = {
		"pistol": {
			"damage": [pistolDmgProgressBar, shop.pistolDmgCost, 0, 1.25],
			"accuracy": [pistolAccProgressBar, shop.pistolAccCost, 0, 2],
			"bulletSpeed": [pistolBSProgressBar, shop.pistolBSCost, 0, 62.5],
#			"dUp": 1.25,
#			"aUp": 2,
#			"bsUp": 62.5
		},
		"rifle": {
			"damage": [rifleDmgProgressBar, shop.rifleDmgCost, 0, 2.5],
			"accuracy": [rifleAccProgressBar, shop.rifleAccCost, 0, 1.25],
			"bulletSpeed": [rifleBSProgressBar, shop.rifleBSCost, 0, 75],
#			"dUp": 2.5,
#			"aUp": 1.25,
#			"bsUp": 75
		},
		"shotgun": {
			"damage": [shotgunDmgProgressBar, shop.shotgunDmgCost, 0, 2.5],
			"accuracy": [shotgunAccProgressBar, shop.shotgunAccCost, 0, 7.5],
			"bulletSpeed": [shotgunBSProgressBar, shop.shotgunBSCost, 0, 200],
#			"dUp": 2.5,
#			"aUp": 7.5,
#			"bsUp": 200
		},
		"melee": {
			"damage": [meleeDmgProgressBar, shop.meleeDmgCost, 0, 5],
		}
	}
	update_money_label()

@rpc("any_peer", "call_local")
func update_hud():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
#		if shop.visible: # hide HUD when shop is open
#			HUD.visible = false
#		else:
#			HUD.visible = true
		HUD.moneyText.text = str(money)
		# Calculate max health to healthbar
		HUD.healthBar.max_value = maxHealth
		HUD.healthBar.value = health
		
		for buttonIndex in range(HUD.hotBarButtons.size()):
			if buttonIndex == currentWeaponIndex:
				HUD.hotBarButtons[buttonIndex].disabled = false
			else:
				HUD.hotBarButtons[buttonIndex].disabled = true
		

func update_money_label():
	shopMoneyLabel.text = str(money) + " Credits"
	update_hud.rpc()
	
@rpc("any_peer", "call_local")
func show_shop():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		shop.visible = true
		update_shop_buttons()
		HUD.visible = false
		update_hud.rpc()
		
@rpc("any_peer", "call_local")
func hide_shop():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		shop.visible = false
		HUD.visible = true
		update_hud.rpc()

@rpc("any_peer", "call_local")
func show_ready():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		readyPrompt.visible = true
		
@rpc("any_peer", "call_local")
func hide_ready():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		readyPrompt.visible = false

func update_shop_buttons():
	for i in shopButtons.size():
		if money < shopPrices[i]:
			shopButtons[i].visible = false
		else:
			shopButtons[i].visible = true

func player_upgrade(subject, stat):
	upgrade_stats.rpc(subject, stat)

@rpc("any_peer", "call_local")
func upgrade_stats(subject, stat):
	print("Upgrade Pressed " + " " + subject + " " + stat )
	match subject:
		"player":
			upgrade_player(stat)
		"pistol":
			upgrade_pistol(stat)
		"rifle":
			upgrade_rifle(stat)
		"shotgun":
			upgrade_shotgun(stat)
		"melee":
			upgrade_melee(stat)
	update_money_label()
	update_shop_buttons()

func upgrade_player(stat):
	print("Upgrading player " + stat)
	match stat:
		"health":
			health += 25
			maxHealth = health
			healthProgressBar.value += 25
			set_money(-shop.playerHealthCost)
		"speed":
			speed += 25
			maxSpeed = speed
			speedProgressBar.value += 25
			set_money(-shop.playerSpeedCost)
		"dash":
			canDash = true
			dashProgressBar.value = 100
			set_money(-shop.playerDashCost)

# General function
func upgrade_weapon(weapon, stat):
	print("Upgrading " + weapon + " " + stat)
	if weaponUpgrades.has(weapon) and weaponUpgrades[weapon].has(stat):
		var values = weaponUpgrades[weapon][stat]
		values[0].value += 25 # Progress Bar Value
		set_money(-values[1]) # Upgrade Cost
		weaponUpgrades[weapon][stat][2] += weaponUpgrades[weapon][stat][3] # Stat - Stat Up
		print(weaponUpgrades[weapon])
#		upgrade_weapon_stat(weapon, stat)

func upgrade_pistol(stat):
	upgrade_weapon("pistol", stat)

func upgrade_rifle(stat):
	upgrade_weapon("rifle", stat)

func upgrade_shotgun(stat):
	upgrade_weapon("shotgun", stat)

func upgrade_melee(stat):
	upgrade_weapon("melee", stat)
	
func upgrade_weapon_stat(weapon, stat):
	if weaponMods.has(weapon) and weaponMods[weapon].has(stat):
		# dUp - dmg up
		# aUp - acc up
		# bsUp - bulletspeed up
		print("Weapon Mod")
		match stat:
			"damage":
				weaponMods[weapon][stat] += weaponMods[weapon]["dUp"]
			"accuracy":
				weaponMods[weapon][stat] += weaponMods[weapon]["aUp"]
			"bulletSpeed":
				weaponMods[weapon][stat] += weaponMods[weapon]["bsUp"]
		print("Weapon Mod")
		print(weaponMods[weapon])

func set_money(value):
	SoundManager.pickup.play()
	money += value

func update_gun_rotation():
	# Rotates the gun arrow according to the mouse position
#	gunRotation.look_at(get_global_mouse_position())
	weaponsManager.look_at(get_global_mouse_position())
	pass

func update_animation():
	flip_sprite()
	# Updates player animation based on velocity
	if velocity != Vector2.ZERO:
		anim.play("run")
	else:
		anim.play("idle")

func update_camera(delta):
	if Input.is_action_pressed("ZoomIn"):
		playerCamera.zoomFactor += 0.01
	elif Input.is_action_pressed("ZoomOut"):
		playerCamera.zoomFactor -= 0.01
	else:
		playerCamera.zoomFactor = 1.0
	
func flip_sprite():
	# Flipts the sprite depending on the mouse position
	if get_global_mouse_position().x < global_position.x:
		anim.flip_h = true
	elif get_global_mouse_position().x > global_position.x:
		anim.flip_h = false
		
func check_hit():
	if health <= 0:
		die.rpc()
	
@rpc("any_peer", "call_local")
func switch_weapon(index):	
	SoundManager.weaponSwitch.play()
	currentWeaponIndex = index
	currentWeapon.get_node("ArrowIndicator").texture = load(weaponsData[currentWeaponIndex].texture)
	currentWeapon.get_node("FireCooldown").wait_time = weaponsData[currentWeaponIndex].wait_time
	
@rpc("any_peer", "call_local")
func fire(held_down):
	if GameManager.gameOver: return 
	if held_down:
		weapon_held_down = true
	elif !held_down:
		weapon_held_down = false
	
	while weapon_held_down:
		if dead or GameManager.gameOver:
			break
		if currentWeapon.get_node("FireCooldown").is_stopped():
			SoundManager.gunSounds[currentWeaponIndex].play()
			# add the mods from weaponMods
			dmgAdd = weaponUpgrades.values()[currentWeaponIndex]["damage"][2]
			if currentWeaponIndex != 3:
				accSub = weaponUpgrades.values()[currentWeaponIndex]["accuracy"][2]
				bulletSpeedAdd = weaponUpgrades.values()[currentWeaponIndex]["bulletSpeed"][2]

				var currentWeaponData = weaponsData[currentWeaponIndex]
				
				var multishot = currentWeaponData.multishot
				var deviation_angle = currentWeaponData.deviation_angle - accSub
				for i in range(multishot):
					if multiplayer.is_server():
						var bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BulletSpawner")
						bulletSpawner.spawn([
							currentWeapon.get_node("BulletSpawn").global_position, # position
							currentWeaponData.bullet_speed + bulletSpeedAdd, # bulletSpeed
							currentWeaponData.damage + dmgAdd, # Damage
							weaponsManager.rotation_degrees + randi_range(-deviation_angle, deviation_angle), # bullet rotation
							currentWeaponData.bullet_life
						])
				
			else:
				melee()
			
			currentWeapon.get_node("FireCooldown").start()
			
		await get_tree().create_timer(0.2).timeout
	pass

func melee():
	var currentWeaponData = weaponsData[currentWeaponIndex]
	currentWeapon.get_node("ArrowIndicator").visible = false
	meleeNode.visible = true
	meleeNode.dmg = currentWeaponData.damage + dmgAdd
	meleeNode.position = currentWeapon.get_node("BulletSpawn").position
#	meleeNode.rotation_degrees = weaponsManager.rotation_degrees
	meleeNode.play_melee()

func finished_anim():
	currentWeapon.get_node("ArrowIndicator").visible = true
	meleeNode.visible = false

func handle_hit(dmg):
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		iFramesTimer.start()
		SoundManager.playerHit.play()
		health -= dmg
		print("Player hit", health)
		update_hud.rpc()
	
func toggle_ready():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		SoundManager.click.play()
		readyState = !readyState
#		var idSelf = multiplayer.get_unique_id()
#		var playerSelf = GameManager.players[idSelf]
#		playerSelf["readyState"] = readyState
#		update_ready.emit()
		readyPrompt.update_ready_count()

@rpc("any_peer", "call_local")
func die():
	dead = true
	SoundManager.playerDeath.play()
	anim.play("death")
	collision.disabled = true

func _on_animated_sprite_2d_animation_finished():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		start_respawn.rpc()

@rpc("any_peer", "call_local")
func start_respawn():
	respawn = true

func display_respawn():
	respawn = false
	respawnLabel.text = "Respawning In: %0.1fs" % respawnTimer.time_left

func _on_respawn_timer_timeout():
	var root = get_tree().get_root()
	var playerSpawnPoint = root.get_node("TestMultiplayerScene/PlayerSpawnPoints")
	var spawnPoints = playerSpawnPoint.get_children()

	var randomIndex = randi_range(0, spawnPoints.size() - 1)
	var randomSpawnPoint = spawnPoints[randomIndex].position
	
	self.position = randomSpawnPoint
	
	dead = false
	respawnLabel.hide()
	collision.disabled = false
	health = maxHealth
	update_hud.rpc()
