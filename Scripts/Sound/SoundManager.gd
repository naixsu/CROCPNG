extends Node


@onready var globalSounds = $GlobalSounds

@onready var click = $GlobalSounds/Click
@onready var type = $GlobalSounds/Type
@onready var pickup = $GlobalSounds/Pickup
@onready var collHit = $GlobalSounds/CollHit
@onready var enemyHit = $EnemySounds/EnemyHit


@onready var pistol = $PlayerSounds/Pistol
@onready var rifle = $PlayerSounds/Rifle
@onready var shotgun = $PlayerSounds/Shotgun
@onready var playerHit = $PlayerSounds/PlayerHit

var gunSounds : Array



# Called when the node enters the scene tree for the first time.
func _ready():
	gunSounds = [pistol, rifle, shotgun] # Replace with function body.


func outside_tree_coll_hit():
	collHit.play()
	print("outside_tree_coll_hit")
