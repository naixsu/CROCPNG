extends CharacterBody2D

class_name Player
###
# Grouped to: Player
###

# Export vars here
@export var speed = 300
@export var dashSpeed = 800
@export var dashLength = 0.3
@export var health = 100
@export var Bullet : PackedScene
@export var Enemy : PackedScene
@export var BulletCB : PackedScene

# Onready vars here
@onready var anim = $AnimatedSprite2D
@onready var gunRotation = $GunRotation
@onready var fireCooldown = $FireCooldown
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer
@onready var dash = $Dash

# Camera Onready Vars TO BE DEBUGGED
@onready var playerCamera = $Camera2D

@onready var readyPrompt = get_tree().get_root().get_node("TestMultiplayerScene/ReadyPrompt")
@onready var readyLabel = $ReadyLabel

# Signals here
signal player_fired_bullet(bullet, pos, dir)
signal update_ready

# Other global vars here
var dead = false
var spawn_points = []
var tempSpeed = speed
@export var readyState = false # had to avoid 'ready' builtin keyword
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
		speed = dashSpeed if dash.is_dashing() else tempSpeed
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

		if Input.is_action_just_pressed("Dash"):
			var mouse_direction = get_local_mouse_position().normalized()
			velocity = Vector2(dashSpeed * mouse_direction.x, dashSpeed * mouse_direction.y)
			dash.start_dash(dashLength)
		
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
		
#	if event.is_action_pressed("Spawn"):
#		spawn.rpc()
	pass


func can_shoot_in_physics():
	if Input.is_action_just_pressed("Fire"):
		fire.rpc()	

func update_gun_rotation():
	# Rotates the gun arrow according to the mouse position
	gunRotation.look_at(get_global_mouse_position())

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
func fire():
	if fireCooldown.is_stopped():
		print("Fire")
		var b = BulletCB.instantiate()
		b.global_position = gunRotation.get_node("BulletSpawn").global_position
		b.rotation_degrees = gunRotation.rotation_degrees
##		Add bullet to the tree
		get_tree().root.add_child(b)
		
#		var b = Bullet.instantiate()
#		b.global_position = gunRotation.get_node("BulletSpawn").global_position
#		b.rotation_degrees = gunRotation.rotation_degrees
#	# 	Add bullet to the tree
#		get_tree().root.add_child(b)
	#
	#	# Set direction of bullet
	#	var target = get_global_mouse_position()
	#	var direction_to_mouse = b.global_position.direction_to(target).normalized()
	#	b.set_direction(direction_to_mouse)
		
		# Commenting coz of synch issues
		# Add bullet to the tree
	#	get_tree().root.add_child(b)
#		var target = get_global_mouse_position()
#		var pos = gunRotation.get_node("BulletSpawn").global_position
#		var directionToMouse = pos.direction_to(target).normalized()
#		emit_signal("player_fired_bullet", b, pos, directionToMouse)

		fireCooldown.start()


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
