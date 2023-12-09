extends CharacterBody2D

@export var speed = 1000
@export var damage = 20
@onready var SoundManager = $SoundManager

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

func destroy_self():
	if multiplayer.is_server():
		SoundManager.collHit.play()
		queue_free()
	
func _physics_process(delta):
	velocity = speed * direction
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		if collider is Object:
			if collider.is_in_group("Enemy"):
				collider.handle_hit(damage)
				if multiplayer.is_server(): queue_free()
				
			if collider.is_in_group("Player"):
				if not collider.showIframes:
					collider.handle_boss_bullet.rpc(damage)
				if multiplayer.is_server(): queue_free()
			
			if collider.is_in_group("Platform"):
				collider.handle_hit()
				if multiplayer.is_server(): queue_free()
