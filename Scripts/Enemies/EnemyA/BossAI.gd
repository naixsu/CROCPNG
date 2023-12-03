extends Node2D

signal state_changed(new_state)

enum State {
	IDLE,
	OBJECTIVE,
	ATTACKING,
	DEAD
}
@onready var navigationAgent = $"../NavigationAgent2D"

var current_state = State.OBJECTIVE : set = set_state
var player: Player = null
var parent: Boss = null
var i = 0
var markers : Array

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
	var navPathParent = navRegion.get_node("BossPath")
	var pathPoints = navPathParent.get_children()
	markers = pathPoints
	set_state(State.OBJECTIVE)
	

func set_movement_target(targetPoint: Vector2):
	navigationAgent.target_position = targetPoint
	

func _physics_process(delta):	
	if parent.health <= 0:
		set_state(State.DEAD)
	
	match current_state:
		State.DEAD:
			parent.handle_death()
		State.OBJECTIVE:
			parent.run()

			#Checks if the current target was reached and goes directly to the next one
			if navigationAgent.is_navigation_finished():
				i += 1
				if i >= markers.size():
					set_state(State.IDLE)
					reachedFinal = true
					
					if parent.hasBomb:
						parent.handle_bomb_drop()
					
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
#			parent.coll = parent.move_and_collide(parent.velocity * delta)
		State.ATTACKING:
			parent.attack_player(player)


func initialize(parent):
	self.parent = parent

func set_state(new_state):
	if new_state == current_state:
		return
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player") and current_state != State.DEAD:
		print("Colliding with player")
		player = body
		set_state(State.ATTACKING)

		
