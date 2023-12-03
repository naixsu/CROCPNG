extends Node2D

enum Pattern {
	COUNTER,
	CLOCKWISE,
	STATIONARY
}

var currentPattern = Pattern.COUNTER : set = set_pattern
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
var step

func _ready():
	set_pattern_variables()
	
	match currentPattern:
		Pattern.CLOCKWISE:
			alpha = 3
		Pattern.COUNTER:
			alpha = 3
	
	
	step = (spawnPointCount / 2) * 10


func shoot_clockwise(angle):
	if multiplayer.is_server():
		get_vector(angle)
		var bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")
		bulletSpawner.spawn([
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			theta, # rotation
			bulletLifeTime # lifetime
		])

func shoot_counter(angle):
	if multiplayer.is_server():
		get_vector(angle)
		var bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")
		bulletSpawner.spawn([
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			-theta, # rotation
			bulletLifeTime # lifetime
		])

func initialize(parent):
	self.parent = parent

func set_pattern_variables():
#	set_pattern(randi_range (0, 4))
	rotateSpeed = randi_range (100, 300)
	spawnPointCount = randi_range (6, 8)
	shootTimerWaitTime = randf_range (0.6, 1.0)
	print("speed: %d, count: %d, wait_time: %1f" % [rotateSpeed, spawnPointCount, shootTimerWaitTime])

func set_pattern(newPattern):
	if newPattern == currentPattern:
		return
	
	currentPattern = newPattern
	
func get_vector(angle):
	theta = angle + alpha + step
	var rot = Vector2(cos(theta), sin(theta))
#	print(rot)
	return rot

func _on_speed_timeout():
	match currentPattern:
		Pattern.CLOCKWISE:
			shoot_clockwise(theta)
		Pattern.COUNTER:
			shoot_counter(theta)
