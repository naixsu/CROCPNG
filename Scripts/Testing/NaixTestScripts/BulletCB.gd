extends CharacterBody2D

@export var speed = 1000
@export var damage = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 0
var direction : Vector2

func _ready():
	direction = Vector2(1, 0).rotated(rotation)
	
func change_stats(new_speed, new_damage):
	speed = new_speed
	damage = new_damage
	
func _physics_process(delta):
	# Add the gravity.
	velocity = speed * direction
	if not is_on_floor():
		velocity.y += gravity * delta


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
		
		print("collider ", collider)
		
		if collider is Object:
			var collisionLayer = collider.get_collision_layer()
			var collisionMask = collider.get_collision_mask()
			
#			print("collider ", collider)
#			print("class name ", collider.get_class())
			print("I collided with ", collisionLayer)
			print("I'm on mask ", collisionMask)
			if collider.is_in_group("Enemy"):
				print("Collided with enemy ", collider)
				collider.handle_hit(damage)
				queue_free()
			if collider.is_in_group("Player"):
				print("Collided with player. Ignoring ", collider)
			
			if collider.is_in_group("Platform"):
				print("Collided with platform ", collider)
				queue_free()
#			if collisionLayer == 1:
#				if collisionMask == 4: # Enemy
#					print("collided with Enemy", collider)
#					collider.handle_hit()		
#					print(collider.is_in_group("Enemy"))
#					queue_free()
#				elif collisionMask == 2: # Platform
#					print("collided with Platform", collider)
#					queue_free()
#
#				elif collisionMask == 256: # Player
#					print("Colliding with player. Ignoring")
				

			
