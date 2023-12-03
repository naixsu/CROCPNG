extends Node


@onready var globalSounds = $GlobalSounds

@onready var click = $GlobalSounds/Click
@onready var type = $GlobalSounds/Type
@onready var pickup = $GlobalSounds/Pickup
@onready var playerSounds = $PlayerSounds

@onready var pistol = $PlayerSounds/Pistol
@onready var rifle = $PlayerSounds/Rifle
@onready var shotgun = $PlayerSounds/Shotgun

var gunSounds : Array



# Called when the node enters the scene tree for the first time.
func _ready():
	gunSounds = [pistol, rifle, shotgun] # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
