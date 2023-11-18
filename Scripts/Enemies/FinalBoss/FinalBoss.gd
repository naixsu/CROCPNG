extends Enemy

@onready var shootTimer = $ShootTimer
@onready var rotater = $Rotater
@onready var bulletManager = $BulletManager
@onready var bullet = $Bullet

const rotateSpeed = 100
const shootTimerWaitTime = 0.2
const spawnPointCount = 4
const radius = 100

func _ready():
	var step = 2 * PI / spawnPointCount #The angle between two spawn points

	for i in range(spawnPointCount):
		var spawnPoint = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawnPoint.position = pos
		spawnPoint.rotation = pos.angle()
		rotater.add_child(spawnPoint)

	shootTimer.wait_time = shootTimerWaitTime
	shootTimer.start()

func _process(delta: float) -> void:
	var newRotation = rotater.rotation_degrees + rotateSpeed
	rotater.rotation_degrees = fmod(newRotation, 360)

func _on_shoot_timer_timeout():
	for s in rotater.get_children():
		bulletManager.handle_bullet_spawned(bullet, body.global_position, body.global_direction)
		
