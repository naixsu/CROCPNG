extends Node2D

enum Pattern {
	COUNTER,
	CLOCKWISE,
	STATIONARY
}

var currentPattern = Pattern.CLOCKWISE : set = set_pattern
var rotateSpeed
var shootTimerWaitTime
var spawnPointCount
var parent: Boss = null
const radius = 100
var direction
var theta: float = 0.0
@export var bulletSpeed = 800
@export var bulletLifeTime = 4
@export_range(0, 2 * PI) var alpha: float = 0.0

func _ready():
	set_pattern_variables()
#	var step = 2 * PI / spawnPointCount # The angle between two spawn points
#
#	for i in range(spawnPointCount):
#		var spawnPoint = Node2D.new()
#		var pos = Vector2(radius, 0).rotated(step * i)
#		spawnPoint.position = pos
#		spawnPoint.rotation = pos.angle() 
##		rotater.add_child(spawnPoint)

func shoot(angle):
	if multiplayer.is_server():
		var bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")
		bulletSpawner.spawn([
			parent.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			get_vector(angle), # bullet rotation
			bulletLifeTime # lifetime
		])

func initialize(parent):
	self.parent = parent

func set_pattern_variables():
	set_pattern(randi_range (0, 4))
	rotateSpeed = randi_range (100, 300)
	spawnPointCount = randi_range (6, 8)
	shootTimerWaitTime = randf_range (0.6, 1.0)
	print("speed: %d, count: %d, wait_time: %1f" % [rotateSpeed, spawnPointCount, shootTimerWaitTime])



func set_pattern(newPattern):
	if newPattern == currentPattern:
		return
	
	currentPattern = newPattern
	

func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))


func _on_speed_timeout():
	shoot(theta)
