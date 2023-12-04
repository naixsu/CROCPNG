extends Node2D

enum Pattern {
	COUNTER,
	CLOCKWISE,
	CLOVER,
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
#@export_range(0, 2 * PI) var alpha: float = 0.0
@export var alpha: float = 0.0
var step : float
var interval : float
var rightAngle : int = 90
var maxAngle : float = 360
var circleDiv : float
var bulletSpawner 
@onready var bulletInterval = $BulletInterval


func _ready():
	bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")
	
	set_pattern_variables()
	# set_pattern(Pattern.CLOCKWISE)
	set_step()
	interval = rightAngle / step
	circleDiv = maxAngle / step
#	print("Step %d Spawnpointcount %d" % [step, spawnPointCount])

	

func set_step():
	match currentPattern:
		Pattern.CLOCKWISE, Pattern.COUNTER:
			step = 6
			bulletInterval.set_wait_time(0.5)
		Pattern.CLOVER:
			pass
	

	


func shoot_clockwise(angle):
	if multiplayer.is_server():
		get_vector(angle)
		
		if currentPattern == Pattern.COUNTER:
			theta *= -1 
		
		for i in range(2):
#			print((theta * (i + 1)) + (interval * step) + circleDiv)
			
#			var rot = (theta * (i + 1)) + (interval * step) + circleDiv
			var rot = theta + ((maxAngle / 2) * i)
			print(rot)
			bulletSpawner.spawn([
				self.global_position, # position
				bulletSpeed, # bulletSpeed
				parent.resource.damage, # damage
#				theta + (interval * step), # rotation
				rot, # rotation
				bulletLifeTime # lifetime
			])
		print("\n")
			
	
	
	

func shoot_clover(angle):
	if multiplayer.is_server():
		get_vector(angle)
		
		if currentPattern == Pattern.COUNTER:
			theta *= -1 
		
		for i in range(step):
#			print((theta * (i + 1)) + (interval * step) + circleDiv)
			
#			var rot = (theta * (i + 1)) + (interval * step) + circleDiv
			var rot = theta + (circleDiv * i)
			print(rot)
			bulletSpawner.spawn([
				self.global_position, # position
				bulletSpeed, # bulletSpeed
				parent.resource.damage, # damage
#				theta + (interval * step), # rotation
				rot, # rotation
				bulletLifeTime # lifetime
			])
		print("\n")

func initialize(parent):
	self.parent = parent

func set_pattern_variables():
#	set_pattern(randi_range (0, 4))
	rotateSpeed = randi_range (100, 300)
#	spawnPointCount = randi_range (6, 8)
	shootTimerWaitTime = randf_range (0.6, 1.0)
#	print("speed: %d, count: %d, wait_time: %1f" % [rotateSpeed, spawnPointCount, shootTimerWaitTime])

func set_pattern(newPattern):
	if newPattern == currentPattern:
		return
	
	currentPattern = newPattern
	
func get_vector(angle):
	# update theta
#	theta = angle + alpha + step
#	theta = angle + step
#	theta = (angle + interval) % maxAngle
	theta = fmod(angle + interval, maxAngle)
	print("theta " + str(theta))
#	theta = 180
	var rot = Vector2(cos(theta), sin(theta))
#	print(rot)
	return rot

func _on_speed_timeout():
	match currentPattern:
		Pattern.CLOCKWISE:
			shoot_clockwise(theta)
		Pattern.COUNTER:
			shoot_clockwise(theta)
		Pattern.CLOVER:
			shoot_clover(theta)
