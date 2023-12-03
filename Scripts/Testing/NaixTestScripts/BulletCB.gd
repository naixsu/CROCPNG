extends CharacterBody2D

@export var speed = 1000
@export var damage = 20
@onready var SoundManager = $SoundManager

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 0
var direction : Vector2

func _ready():
	direction = Vector2(1, 0).rotated(rotation)
	
func set_timer(bullet_life):
	var timer := Timer.new()
	
	
	timer.wait_time = bullet_life
	timer.one_shot = true	
	timer.autostart = true
	
	timer.connect("timeout", destroy_self)
	add_child(timer)
	
func change_stats(new_speed, new_damage):
	speed = new_speed
	damage = new_damage

func destroy_self():
	if multiplayer.is_server():
		SoundManager.collHit.play()
		queue_free()
	
func _physics_process(delta):
	# Add the gravity.
	velocity = speed * direction

#	move_and_slide()
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		# Remember that CollLayer and CollMask are bit integers
		# PhysicsObject - CollLayer - CollMask
		# Player - 2 - 9 # Might change this to 1 later when I figure out how CollLayer and CollMask actually works
		# Enemy - 1 - 3
		# Platform - 1 - 2
		# Bullet - 1 - 24
		
#		print("collider ", collider)
		
		if collider is Object and multiplayer.is_server():
			var collisionLayer = collider.get_collision_layer()
			var collisionMask = collider.get_collision_mask()
			

			if collider.is_in_group("Enemy"):
				print("Collided with enemy ", collider)
				collider.handle_hit(damage)
				queue_free()
				
			if collider.is_in_group("Player"):
#				print("Collided with player. Ignoring ", collider)
				collider.handle_hit(damage)
				queue_free()
			
			if collider.is_in_group("Platform"):
				collider.handle_hit()
				queue_free()

