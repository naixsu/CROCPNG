extends Node2D

class_name Boss

@onready var anim = $Anim
@onready var ai = $AI
@onready var target = $Target
@onready var SoundManager = $SoundManager
@onready var bulletHell = $BulletHell
@onready var collision = $CollisionShape2D
@onready var healthLabel = $Label
@onready var bloodsplash = $bloodsplash

@export var health : int
@export var speed : int
@export var resource : Resource
@export var dead = false
@export var hasBomb : bool = false
@export var bulletDmg : int

# Called when the node enters the scene tree for the first time.
func _ready():
	init_enemy()
	anim.play("run")
	ai.initialize(self)
	ai.connect("state_changed", on_state_changed)
	bulletHell.initialize(self)
	bulletDmg = resource.damage

func _process(_delta):
	healthLabel.text = str(max(health, 0))
	
	if hasBomb:
		target.visible = true
	else:
		target.visible = false


func init_enemy():
	self.health = resource.health
	self.speed = resource.speed

func on_state_changed(new_state):
	print("BOSS ", new_state)
	
func idle():
	anim.play("idle")
	
func run():
	anim.play("run")

func attack_player(player):
	if not player.showIframes:
		player.handle_hit(resource.damage)

func handle_bomb_drop():
	if multiplayer.is_server():
		var root = get_tree().get_root()
		var multiplayerScene = root.get_node("TestMultiplayerScene")
		multiplayerScene.spawn_bomb(self.position)
		hasBomb = false

func handle_bomb_transfer():
	if multiplayer.is_server():
		var root = get_tree().get_root()
		var multiplayerScene = root.get_node("TestMultiplayerScene")
		multiplayerScene.find_to_hold_bomb.rpc()

func handle_hit(dmg):
	SoundManager.enemyHit.play()
	health -= dmg
	bloodsplash.emitting = true

func handle_death():
	if not dead:
		dead = true
		if hasBomb:
			handle_bomb_transfer()
		collision.disabled = true
		hasBomb = false
		anim.play("death")

func _on_anim_animation_finished():
	if multiplayer.is_server():
		subtract_enemy.rpc()
		queue_free()

@rpc("any_peer", "call_local")
func subtract_enemy():
	GameManager.enemyCount -= 1
