extends CharacterBody2D

class_name Enemy
###
# Grouped to: Enemy
###

@onready var anim = $AnimatedSprite2D
@onready var ai = $AI
@onready var multiplayerSynchronizer = $MultiplayerSynchronizer
@export var player: Player
@export var health : int
@export var speed : int
@onready var collision = $CollisionShape2D

@export var movementTargets: Array[Node2D]
@export var resource : Resource
@export var spawn : int
@export var dead = false
@onready var healthLabel = $Label

###
# EnemyA = Skeleton
# EnemyB = Ghost
# EnemyC = Slime
###

func _ready():
#	multiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	init_enemy()
	anim.play("idle")
	ai.initialize(self)
	ai.connect("state_changed", on_state_changed)
#	ai.initialize_path_finding()

func _process(delta):
	healthLabel.text = str(health)

func init_enemy():
	self.health = resource.health
	self.speed = resource.speed

func _on_animated_sprite_2d_animation_finished():
	if multiplayer.is_server():
		subtract_enemy.rpc()
		var moneySpawner = get_tree().get_root().get_node("TestMultiplayerScene/MoneySpawner")
		moneySpawner.spawn([self.position])
		await get_tree().physics_frame # Delay queue a bit
		queue_free()

@rpc("any_peer", "call_local")
func subtract_enemy():
	GameManager.enemyCount -= 1

func handle_hit(dmg):
	health -= dmg
	print("Enemy hit", health)

func handle_death():
	if not dead:
		collision.disabled = true
		anim.play("death")
		dead = true

func flip_sprite(player):
	if player.global_position.x < global_position.x:
		anim.flip_h = true
	elif player.global_position.x > global_position.x:
		anim.flip_h = false

func go_towards(player):
	anim.play("run")
	var direction = (player.global_position - global_position).normalized()
	var new_position = global_position + direction * speed * get_process_delta_time()
#	global_position = new_position
	velocity = direction * speed
	move_and_slide()
	
func idle():
	anim.play("idle")
	
func run():
	anim.play("run")

func on_state_changed(new_state):
	print("ENEMY ", new_state)
	
