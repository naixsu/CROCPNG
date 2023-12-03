extends Node2D

class_name Boss

@onready var anim = $Anim
@onready var ai = $AI
@onready var target = $Target

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

func run():
	anim.play("run")

func attack_player(player):
	if player.iFramesTimer.is_stopped():
		print("Attacking player " + str(player.name))
		player.handle_hit(resource.damage)
