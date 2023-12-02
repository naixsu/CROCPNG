extends Node2D

signal state_changed(new_state)

enum State {
	IDLE,
	ENGAGE,
	DEAD,
	OBJECTIVE
}

@onready var detectionZone = $DetectionZone
@onready var navigationAgent = $"../NavigationAgent2D"
@onready var spawnDetector = $SpawnDetector

var current_state = State.IDLE : set = set_state
var player: Player = null
var parent: Enemy = null
var i = 0
var markers : Array
var foundInitialSpawn = false
var spawn: int
var reachedFinal = false

func initialize_path_finding():
	navigationAgent.path_desired_distance = 4.0
	navigationAgent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")
#
#	#Below is the beginning for the pathfinding
##	set_movement_target(parent.movementTargets[i].position) #Very first target position
#	init_pathfinding(parent)
#	i += 1

func actor_setup():
	
	if parent.dead: return
	
	# await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout
	
	# Set paths
	var root = get_tree().get_root()
	var navRegion = root.get_node("TestMultiplayerScene/NavArea/NavRegion")
	var navPathParent = navRegion.get_node(str(spawn))
	var pathPoints = navPathParent.get_children()
	
	if spawn == 3: # Determine split paths when enemies spawn at area 3
		# Split paths are LEFT and RIGHT
		# LEFT: 0, 2, 4
		# RIGHT: 1, 3, 5
		var random_choice = randi_range(0, 1) # LEFT: 0 | RIGHT: 1
		# Hard coding. Feel free to optimize
		markers.append(pathPoints[0])
		if random_choice == 0:
			markers.append(pathPoints[1])
			markers.append(pathPoints[2])
			markers.append(pathPoints[3])
		else:
			markers.append(pathPoints[4])
			markers.append(pathPoints[5])
			markers.append(pathPoints[6])
		markers.append(pathPoints[7])
		markers.append(pathPoints[8])
		markers.append(pathPoints[9])
		markers.append(pathPoints[10])
	else:
		markers = pathPoints
		
	# Set state after init
	set_state(State.OBJECTIVE)
	

func set_movement_target(targetPoint: Vector2):
	navigationAgent.target_position = targetPoint
	

func _physics_process(delta):	
	if parent.health <= 0:
		set_state(State.DEAD)
	
	match current_state:
		State.IDLE:
			parent.idle()
		State.ENGAGE:
			if player != null:
#				set_movement_target(Vector2.ZERO)
				parent.flip_sprite(player)
				var threshold_distance = 100
				if parent.global_position.distance_to(player.global_position)\
					> threshold_distance:
					parent.go_towards(player)
				else:
					parent.idle()
			else:
				print("No player found")
				set_state(State.IDLE)
		State.DEAD:
			parent.handle_death()
		State.OBJECTIVE:
			parent.run()
#			return 
			parent.flip_sprite(markers[i])
			#Checks if the current target was reached and goes directly to the next one
			if navigationAgent.is_navigation_finished():
				i += 1
				if i >= markers.size():
					set_state(State.IDLE)
					reachedFinal = true
					return
				set_movement_target(markers[i].position)

			var currentAgentPosition: Vector2 = global_position #Position of the enemy relative to the world
#			var nextPathPosition: Vector2 = navigationAgent.get_next_path_position()
			var nextPathPosition = markers[i].position
			var newVelocity: Vector2 = nextPathPosition - currentAgentPosition

			newVelocity = newVelocity.normalized()
			newVelocity = newVelocity * parent.speed

			parent.velocity = newVelocity
			parent.move_and_slide()
			
	

func initialize(parent):
	self.parent = parent

func set_state(new_state):
	if new_state == current_state:
		return
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _on_detection_zone_body_entered(body):
	print("_on_detection_zone_body_entered ", body)
	if body.is_in_group("Player") and current_state != State.DEAD and current_state != State.ENGAGE:
		set_state(State.ENGAGE)
		player = body

func _on_detection_zone_body_exited(body):
	if body.is_in_group("Player") and current_state != State.DEAD: # Player exited radius
		# Check if there are still nav markers
		if reachedFinal:
			i -= 1
			set_movement_target(markers[i].position)
		if navigationAgent.is_navigation_finished():
			if i >= markers.size():
				set_state(State.IDLE)
				return
		else:
			set_state(State.OBJECTIVE)
		player = null
		
		# Might wanna check if another player is in the vicinity
		check_for_player()

func check_for_player():
	print("Checking for another player")
	# This is not actually the "nearest" player per se
	# might need to actually calculate and sort this array
	var nearest_player = detectionZone.get_overlapping_bodies() # Array
	
	if len(nearest_player) > 0: # Player/s found
		_on_detection_zone_body_entered(nearest_player[0])


func _on_spawn_detector_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	# Get name of parent
	# o, 1, 2, 3, 4, n
	if foundInitialSpawn: return
	# Get parent name and set it to spawn
	var areaName = area.get_parent().name
	spawn = areaName.to_int()
	await get_tree().physics_frame
	print("Set parent " + str(parent.name) + " at Spawn Area: " + str(spawn))
	parent.spawn = spawn
	initialize_path_finding()
	# Toggle state
	foundInitialSpawn = true
