extends Node2D

enum Pattern {
	CLOCKWISE,
	COUNTER,
	CLOVER,
	RADIAL,
	CROSS
}

var currentPattern = Pattern.CLOCKWISE : set = set_pattern
var rotateSpeed
var shootTimerWaitTime
var spawnPointCount = 4
var parent: Boss = null
const radius = 100
var direction
var theta: float = 0.0
@export var bulletSpeed = 800
@export var bulletLifeTime = 4
@export var alpha: float = 0.0
var step : float
var interval : float
var rightAngle : int = 90
var maxAngle : float = 360
var circleDiv : float
var bulletSpawner 
@onready var bulletInterval = $BulletInterval
@onready var patternDuration = $PatternDuration


func _ready():
	bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")

	set_pattern_variables()

func reset_theta():
	theta = 0

func set_step():
	
	match currentPattern:
		Pattern.CLOCKWISE, Pattern.COUNTER:
			step = 2
			bulletInterval.set_wait_time(0.9)
			circleDiv = maxAngle / step
			interval = rightAngle / step

		Pattern.CLOVER:
			step = 6
			bulletInterval.set_wait_time(0.9)
			circleDiv = maxAngle / step
			interval = rightAngle / step

		Pattern.RADIAL:
			step = 8
			bulletInterval.set_wait_time(0.9)
			circleDiv = maxAngle / step
			interval = rightAngle / step

		Pattern.CROSS:
			step = 4
			bulletInterval.set_wait_time(0.9)
			circleDiv = maxAngle / step
			interval = circleDiv / 2
			
	reset_theta()

func spawn_bullet(pos, bulletSpeed, dmg, rot, bulletLifeTime):
	if multiplayer.is_server():
		bulletSpawner.spawn([
			pos, # position
			bulletSpeed, # bulletSpeed
			dmg, # damage
			rot, # rotation
			bulletLifeTime # lifetime
		])

func shoot_clockwise(angle):
	get_vector(angle)
	var flip = 1

	if currentPattern == Pattern.COUNTER:
		flip = -1
	
	for i in range(step):
		var rot = (theta + ((maxAngle / 2) * i)) * flip

		spawn_bullet(
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.bulletDmg, # damage
			rot, # rotation
			bulletLifeTime # lifetime
		)

func shoot_clover(angle):
	get_vector(angle)
	for i in range(step):
		var rot = theta + (circleDiv * i)
		spawn_bullet(
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			rot, # rotation
			bulletLifeTime # lifetime
		)

func shoot_radial(angle):
	get_vector(angle)
	
	for i in range(step):
		var rot = circleDiv * i
		spawn_bullet(
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			rot, # rotation
			bulletLifeTime # lifetime
		)

func shoot_cross(angle):
	get_vector(angle)
	
	for i in range(step):
		var rot = theta + (circleDiv * i)
		spawn_bullet(
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			rot, # rotation
			bulletLifeTime # lifetime
		)

func initialize(parent):
	self.parent = parent

func set_pattern_variables():
	set_pattern(randi_range (0, Pattern.size()))
	set_step()
	
func set_pattern(newPattern):
	if newPattern == currentPattern:
		return
	
	currentPattern = newPattern
	
func get_vector(angle):
	# update theta
	theta = fmod(angle + interval, maxAngle)

	var rot = Vector2(cos(theta), sin(theta))

	return rot

func _on_speed_timeout():
	if parent.dead or parent.ai.current_state == parent.ai.State.IDLE: 
		return # stop shooting
	match currentPattern:
		Pattern.CLOCKWISE:
			shoot_clockwise(theta)

		Pattern.COUNTER:
			shoot_clockwise(theta)

		Pattern.CLOVER:
			shoot_clover(theta)

		Pattern.RADIAL:
			shoot_radial(theta)

		Pattern.CROSS:
			shoot_cross(theta)

	parent.SoundManager.bossShoot.play()


func _on_pattern_duration_timeout():
	var nextPattern = currentPattern + 1

	if nextPattern > Pattern.size() - 1:
		nextPattern = 0

	set_pattern(nextPattern)
	set_step()