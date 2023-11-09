extends CharacterBody2D

# Export vars here
@export var speed = 300

# Other global vars here


func _physics_process(delta):
	
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	
	update_gun_rotation()
	if Input.is_action_just_pressed("Fire"):
		fire()
	
	
	velocity = direction * speed
	move_and_slide()


func update_gun_rotation():
	# Rotates the gun arrow according to the mouse position
	$GunRotation.look_at(get_global_mouse_position())

func fire():
	# Add bullet methods here
	print("Fire")
