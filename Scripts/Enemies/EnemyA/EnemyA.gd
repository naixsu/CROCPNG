extends CharacterBody2D

class_name Enemy
###
# Grouped to: Enemy
###

@onready var anim = $AnimatedSprite2D
@onready var ai = $AI
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer
@export var player: Player
@export var health = 100
@export var speed = 50

@export var movementTargets: Array[Node2D]

func _ready():
	multiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	anim.play("idle")
	ai.initialize(self)
	ai.connect("state_changed", on_state_changed)
	# Delay the initialize_path_finding function
	await get_tree().create_timer(0.5).timeout
	ai.initialize_path_finding()
#	ai.initialize_path_finding()


func _on_animated_sprite_2d_animation_finished():
	queue_free()

func handle_hit():
	health -= 20
	print("Enemy hit", health)

func handle_death():
	anim.play("death")

func flip_sprite(player):
	if player.global_position.x < global_position.x:
		anim.flip_h = true
	elif player.global_position.x > global_position.x:
		anim.flip_h = false

func go_towards(player):
	anim.play("run")
	var direction = (player.global_position - global_position).normalized()
	var new_position = global_position + direction * speed * get_process_delta_time()
	global_position = new_position
	

func idle():
	anim.play("idle")
	
func run():
	anim.play("run")

func on_state_changed(new_state):
	print("ENEMY ", new_state)
	
	
	


	
