extends CharacterBody2D

class_name Player
###
# Grouped to: Player
###

# Export vars here
@export var speed = 300
@export var health = 100
@export var Bullet : PackedScene
@export var Enemy : PackedScene
@export var BulletCB : PackedScene

# Onready vars here
@onready var anim = $AnimatedSprite2D
#@onready var gunRotation = $GunRotation
#@onready var fireCooldown = $GunRotation/FireCooldown
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer
@onready var weaponsManager = $WeaponsManager

# Camera Onready Vars TO BE DEBUGGED
@onready var playerCamera = $Camera2D

@onready var readyPrompt = get_tree().get_root().get_node("TestMultiplayerScene/ReadyPrompt")
@onready var readyLabel = $ReadyLabel

@onready var weaponFile = "res://Scenes/Player/WeaponData.json"

# Signals here
signal player_fired_bullet(bullet, pos, dir)
signal update_ready

# Other global vars here
var dead = false
var spawn_points = []
@export var readyState = false # had to avoid 'ready' builtin keyword

var weapons: Array = []
var weaponsData: Array = []
@export var currentWeaponIndex = 0
var currentWeapon

# multiplayer syncing
#var syncPos = Vector2(0, 0)
#var syncRot = 0

func _ready():
#	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

#	var spawn_point_parent = root.get_node("EnemySpawnPoints")
#	var children = spawn_point_parent.get_children()
#	for child in children:
#		if child is Marker2D:
#			spawn_points.append(child)
	init_weapons(weaponFile)
	readyPrompt.connect("toggle_ready", toggle_ready)

	multiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	anim.play("idle")
	
	#Set the camera to only be active for the local player
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		playerCamera.make_current()

func _process(delta):
	readyLabel.text = str(readyState)


func _physics_process(delta):
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var direction = Input.get_vector("Left", "Right", "Up", "Down")
		
		velocity = direction * speed
#		syncPos = global_position
#		syncRot = rotation_degrees

#		if Input.is_action_just_pressed("Fire"):
#			fire.rpc()
#		can_shoot_in_physics()
		
		# Play the death animation
		# TODO:
		# Remove this later when adding the actual death feature
		if Input.is_action_just_pressed("ui_accept"):
			dead = not dead
			anim.play("death")
		
#		if Input.is_action_just_pressed("Spawn"):
#			var e = Enemy.instantiate()
#			e.global_position = get_global_mouse_position()
#			get_tree().root.add_child(e)
#			print("Spawned Enemy")
		
#		if Input.is_action_just_pressed("Spawn"):
#			spawn.rpc()
			
		if not dead:
			update_gun_rotation()
#			move_and_slide()
			move_and_collide(velocity * delta)
			update_animation()
		

	update_camera(delta)
		
		
#	else: # TODO: Maybe add this in the future
#		global_position = global_position.lerp(syncPos, .5)
#		rotation_degrees = lerpf(rotation_degrees, syncRot, .5)

# Commenting as it has synchronization issues
func _unhandled_input(event): 
	# TODO:
	# Handle Weapon stuff in a separate node for reusability
	# using signals to fire off from Weapon -> Player -> BulletManager
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if event.is_action_pressed("Fire"):
			fire.rpc()
			
		if event.is_action_pressed("SwitchWeapon1"):
#			currentWeaponIndex = 0
			switch_weapon.rpc(0)
		if event.is_action_pressed("SwitchWeapon2"):
#			currentWeaponIndex = 1
			switch_weapon.rpc(1)
		if event.is_action_pressed("SwitchWeapon3"):
#			currentWeaponIndex = 2
			switch_weapon.rpc(2)
		
#	if event.is_action_pressed("Spawn"):
#		spawn.rpc()
	pass

func init_weapons(weaponFile):
	weapons = weaponsManager.get_children()
	currentWeapon = weapons[currentWeaponIndex]
	
	
	var f = FileAccess.open(weaponFile, FileAccess.READ)
	var content = f.get_as_text()
	weaponsData = JSON.parse_string(content)	
	

func can_shoot_in_physics():
	if Input.is_action_just_pressed("Fire"):
		fire.rpc()	

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
		


@rpc("any_peer", "call_remote")
func spawn():
	var e = Enemy.instantiate()
	e.global_position = get_global_mouse_position()
	get_tree().root.add_child(e)
	print("Spawned Enemy")
	

	
@rpc("any_peer", "call_local")
func switch_weapon(index):	
	currentWeaponIndex = index
	currentWeapon.get_node("ArrowIndicator").texture = load(weaponsData[currentWeaponIndex].texture)
	currentWeapon.get_node("FireCooldown").wait_time = weaponsData[currentWeaponIndex].wait_time
	
	

@rpc("any_peer", "call_local")
func fire():
#	if fireCooldown.is_stopped():
#		print("Fire")
#		var b = BulletCB.instantiate()
#		b.global_position = gunRotation.get_node("BulletSpawn").global_position
#		b.rotation_degrees = gunRotation.rotation_degrees
###		Add bullet to the tree
#		get_tree().root.add_child(b)
#		fireCooldown.start()
	if currentWeapon.get_node("FireCooldown").is_stopped():
		print("{0} Fire!".format({
			"0": str(currentWeapon.name)
		}))
#		var b = BulletCB.instantiate()
#		b.global_position = currentWeapon.get_node("BulletSpawn").global_position
		
		#Calculate random bullet spread	and multishot
		var multishot = weaponsData[currentWeaponIndex].multishot
		var deviation_angle = weaponsData[currentWeaponIndex].deviation_angle
		for i in range(multishot):		
			var b = BulletCB.instantiate()
			b.global_position = currentWeapon.get_node("BulletSpawn").global_position
			
			var bullet_rotation = weaponsManager.rotation_degrees + randi_range(-deviation_angle, deviation_angle)
			b.rotation_degrees = bullet_rotation
			
			get_tree().root.add_child(b)
		currentWeapon.get_node("FireCooldown").start()
	pass


func handle_hit():
	health -= 20
	print("Player hit", health)
	

func toggle_ready():
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		readyState = !readyState
#		var idSelf = multiplayer.get_unique_id()
#		var playerSelf = GameManager.players[idSelf]
#		playerSelf["readyState"] = readyState
#		update_ready.emit()
		readyPrompt.update_ready_count()

#func _on_ready_prompt_toggle_ready():
##	print("here")
#	readyState = !readyState
##	print("readyState " + str(readyState))
#	var idSelf = multiplayer.get_unique_id()
#	var playerSelf = GameManager.players[idSelf]
#	playerSelf["readyState"] = readyState
##	var root = get_tree().get_root()
##	var multiplayerController = root.get_node("Multiplayer")
##	multiplayerController.test_pass(str(name), idSelf, readyState)
#	update_ready_state.emit()
