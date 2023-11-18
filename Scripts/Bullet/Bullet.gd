extends CharacterBody2D

@export var speed = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2

func _ready():
	direction = Vector2(1, 0).rotated(rotation)


func _physics_process(delta):
	# Add the gravity.
	velocity = speed * direction
	if not is_on_floor():
		velocity.y += gravity * delta


	move_and_slide()
