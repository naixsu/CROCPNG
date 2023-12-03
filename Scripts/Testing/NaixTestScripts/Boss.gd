extends Node2D

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
	anim.play("run")
	init_enemy()

func _process(delta):
#	healthLabel.text = str(health)
	
	if hasBomb:
		target.visible = true
	else:
		target.visible = false


func init_enemy():
	self.health = resource.health
	self.speed = resource.speed
