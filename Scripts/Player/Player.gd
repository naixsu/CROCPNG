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

# Onready vars here
@onready var anim = $AnimatedSprite2D
@onready var gunRotation = $GunRotation
@onready var fireCooldown = $FireCooldown
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer

# Signals here
signal player_fired_bullet(bullet, pos, dir)

# Other global vars here
var dead = false

func _ready():
	multiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	anim.play("idle")
	
func _physics_process(delta):
	if multiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var direction = Input.get_vector("Left", "Right", "Up", "Down")
		
		velocity = direction * speed
		
		# Play the death animation
		# TODO:
		# Remove this later when adding the actual death feature
		if Input.is_action_just_pressed("ui_accept"):
			dead = not dead
			anim.play("death")
		
		if Input.is_action_just_pressed("Spawn"):
			var e = Enemy.instantiate()
			e.global_position = get_global_mouse_position()
			get_tree().root.add_child(e)
			print("Spawned Enemy")
			
		if not dead:
			update_gun_rotation()
			move_and_slide()
			update_animation()

func _unhandled_input(event):
	# TODO:
	# Handle Weapon stuff in a separate node for reusability
	# using signals to fire off from Weapon -> Player -> BulletManager
	if event.is_action_pressed("Fire"):
		fire()
	

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

func flip_sprite():
	# Flipts the sprite depending on the mouse position
	if get_global_mouse_position().x < global_position.x:
		anim.flip_h = true
	elif get_global_mouse_position().x > global_position.x:
		anim.flip_h = false

func fire():
	if fireCooldown.is_stopped():
		var b = Bullet.instantiate()
#		b.global_position = gunRotation.get_node("BulletSpawn").global_position
#		b.rotation_degrees = gunRotation.rotation_degrees
#	# 	Add bullet to the tree
#		get_tree().root.add_child(b)
	#
	#	# Set direction of bullet
	#	var target = get_global_mouse_position()
	#	var direction_to_mouse = b.global_position.direction_to(target).normalized()
	#	b.set_direction(direction_to_mouse)
		
		# Add bullet to the tree
	#	get_tree().root.add_child(b)
		var target = get_global_mouse_position()
		var pos = gunRotation.get_node("BulletSpawn").global_position
		var direction_to_mouse = pos.direction_to(target).normalized()
		emit_signal("player_fired_bullet", b, pos, direction_to_mouse)
		fireCooldown.start()


func handle_hit():
	health -= 20
	print("Player hit", health)
	
	
	
	
