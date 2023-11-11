extends Node2D

signal state_changed(new_state)

enum State {
	IDLE,
	ENGAGE,
	DEAD
}

@onready var detection_zone = $DetectionZone


var current_state = State.IDLE : set = set_state
var player: Player = null
var parent: Enemy = null


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
		State.DEAD:
			parent.handle_death()


func initialize(parent):
	self.parent = parent

func set_state(new_state):
	if new_state == current_state:
		return
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _on_detection_zone_body_entered(body):
	if body.is_in_group("Player") and current_state != State.DEAD:
		set_state(State.ENGAGE)
		player = body



func _on_detection_zone_body_exited(body):
	if body.is_in_group("Player") and current_state != State.DEAD:
		set_state(State.IDLE)
		player = null
