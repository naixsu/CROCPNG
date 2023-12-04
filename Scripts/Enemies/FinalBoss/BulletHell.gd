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
var step : int
var interval : float
var rightAngle : int = 90
var bulletSpawner 

func _ready():
	bulletSpawner = get_tree().get_root().get_node("TestMultiplayerScene/BossBulletSpawner")
	
	set_pattern_variables()
	# set_pattern(Pattern.CLOCKWISE)
	set_step()
	interval = rightAngle / step
#	print("Step %d Spawnpointcount %d" % [step, spawnPointCount])

	

func set_step():
	match currentPattern:
		Pattern.CLOCKWISE, Pattern.COUNTER:
			step = 6
		Pattern.CLOVER:
			pass
	

	


func shoot_clockwise(angle):
	if multiplayer.is_server():
		get_vector(angle)
		
		if currentPattern == Pattern.COUNTER:
			theta *= -1 
			
		bulletSpawner.spawn([
			self.global_position, # position
			bulletSpeed, # bulletSpeed
			parent.resource.damage, # damage
			theta, # rotation
			bulletLifeTime # lifetime
		])

func shoot_clover(angle):
	if multiplayer.is_server():
		get_vector(angle)
		
		for i in range(spawnPointCount):
			bulletSpawner.spawn([
				self.global_position, # position
				bulletSpeed, # bulletSpeed
				parent.resource.damage, # damage
				theta + (step * spawnPointCount), # rotation
				bulletLifeTime # lifetime
			])

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
	theta = angle + interval
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
