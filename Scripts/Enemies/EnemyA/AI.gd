extends Node2D

signal state_changed(new_state)

enum State {
	IDLE,
	ENGAGE,
	DEAD,
	OBJECTIVE
}

@onready var detectionZone = $DetectionZone
@export var navigationAgent: NavigationAgent2D

var current_state = State.IDLE : set = set_state
var player: Player = null
var parent: Enemy = null
var i = 0

func initialize_path_finding():
	set_state(State.OBJECTIVE)
	navigationAgent.path_desired_distance = 4.0
	navigationAgent.target_desired_distance = 4.0
	
	#Below is the beginning for the pathfinding
	set_movement_target(parent.movementTargets[i].position) #Very first target position
	i += 1
	
func _physics_process(delta):
	
	#Checks if the current target was reached and goes directly to the next one
	if navigationAgent.is_navigation_finished():
		if i >= parent.movementTargets.size():
			set_state(State.IDLE)
			return
		set_movement_target(parent.movementTargets[i].position)
		i += 1

	var currentAgentPosition: Vector2 = global_position #Position of the enemy relative to the world
	var nextPathPosition: Vector2 = navigationAgent.get_next_path_position()
	var newVelocity: Vector2 = nextPathPosition - currentAgentPosition

	newVelocity = newVelocity.normalized()
	newVelocity = newVelocity * parent.speed

	parent.velocity = newVelocity
	parent.move_and_slide()

func set_movement_target(targetPoint: Vector2):
	navigationAgent.target_position = targetPoint
	
func _process(delta):
	if parent.health <= 0:
		set_state(State.DEAD)
	
	match current_state:
		State.IDLE:
			parent.idle()
		State.ENGAGE:
			if player != null:
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
	if body.is_in_group("Player") and current_state != State.DEAD:
		set_state(State.IDLE)
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
	
