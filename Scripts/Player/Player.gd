extends CharacterBody2D

# Export vars here
@export var speed = 300

# Onready vars here
@onready var anim = $AnimatedSprite2D

# Other global vars here
var dead = false

func _ready():
	anim.play("idle")
	

func _physics_process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")

	if Input.is_action_just_pressed("Fire"):
		fire()
	
	velocity = direction * speed
	
	if Input.is_action_just_pressed("ui_accept"):
		dead = not dead
		anim.play("death")
		
	if not dead:
		update_gun_rotation()
		move_and_slide()
		update_animation()
	

func update_gun_rotation():
	# Rotates the gun arrow according to the mouse position
	$GunRotation.look_at(get_global_mouse_position())

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
	# Add bullet methods here
	print("Fire")
