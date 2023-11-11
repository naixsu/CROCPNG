extends CharacterBody2D

# Export vars here
@export var speed = 300
@export var Bullet : PackedScene

# Onready vars here
@onready var anim = $AnimatedSprite2D
@onready var gun_rotation = $GunRotation
@onready var fire_cooldown = $FireCooldown

# Signals here
signal player_fired_bullet(bullet, pos, dir)

# Other global vars here
var dead = false
var health = 100

func _ready():
	anim.play("idle")
	

func _physics_process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	velocity = direction * speed
	
	if Input.is_action_just_pressed("ui_accept"):
		dead = not dead
		anim.play("death")
		
	if not dead:
		update_gun_rotation()
		move_and_slide()
		update_animation()

func _unhandled_input(event):
	if event.is_action_pressed("Fire"):
		fire()
	

func update_gun_rotation():
	# Rotates the gun arrow according to the mouse position
	gun_rotation.look_at(get_global_mouse_position())

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
	if fire_cooldown.is_stopped():
		var b = Bullet.instantiate()
	#	b.global_position = gun_rotation.get_node("BulletSpawn").global_position
	#	b.rotation_degrees = gun_rotation.rotation_degrees
	#
	#	# Set direction of bullet
	#	var target = get_global_mouse_position()
	#	var direction_to_mouse = b.global_position.direction_to(target).normalized()
	#	b.set_direction(direction_to_mouse)
		
		# Add bullet to the tree
	#	get_tree().root.add_child(b)
		var target = get_global_mouse_position()
		var pos = gun_rotation.get_node("BulletSpawn").global_position
		var direction_to_mouse = pos.direction_to(target).normalized()
		emit_signal("player_fired_bullet", b, pos, direction_to_mouse)
		fire_cooldown.start()


func handle_hit():
	health -= 20
	print("Player hit", health)
	
	
	
	
