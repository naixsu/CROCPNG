extends Node2D

class_name Boss

@onready var anim = $Anim
@onready var ai = $AI
@onready var target = $Target
@onready var SoundManager = $SoundManager

@export var health : int
@export var speed : int
@export var resource : Resource
@export var dead = false
@export var hasBomb : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	init_enemy()
	anim.play("run")
	ai.initialize(self)
	ai.connect("state_changed", on_state_changed)

func _process(delta):
#	healthLabel.text = str(health)
	
	if hasBomb:
		target.visible = true
	else:
		target.visible = false


func init_enemy():
	self.health = resource.health
	self.speed = resource.speed
	
	print("Health " + str(health))

func on_state_changed(new_state):
	print("BOSS ", new_state)
	
func idle():
	anim.play("idle")
	
func run():
	anim.play("run")

func attack_player(player):
	if player.iFramesTimer.is_stopped():
		print("Attacking player " + str(player.name))
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
	print("Enemy hit", health)
