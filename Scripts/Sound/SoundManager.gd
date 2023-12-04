extends Node


@onready var globalSounds = $GlobalSounds

@onready var click = $GlobalSounds/Click
@onready var type = $GlobalSounds/Type
@onready var pickup = $GlobalSounds/Pickup
@onready var collHit = $GlobalSounds/CollHit

@onready var enemyHit = $EnemySounds/EnemyHit
@onready var bossShoot = $EnemySounds/BossShoot

@onready var pistol = $PlayerSounds/Pistol
@onready var rifle = $PlayerSounds/Rifle
@onready var shotgun = $PlayerSounds/Shotgun
@onready var melee = $PlayerSounds/Melee
@onready var playerHit = $PlayerSounds/PlayerHit
@onready var weaponSwitch = $PlayerSounds/WeaponSwitch
@onready var playerDeath = $PlayerSounds/PlayerDeath

@onready var finalWave = $WaveSounds/FinalWave
@onready var lose = $WaveSounds/Lose
@onready var win = $WaveSounds/Win

var gunSounds : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	gunSounds = [pistol, rifle, shotgun, melee] # Replace with function body.

