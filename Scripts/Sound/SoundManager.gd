extends Node


@onready var globalSounds = $GlobalSounds

@onready var click = $GlobalSounds/Click
@onready var type = $GlobalSounds/Type
@onready var pickup = $GlobalSounds/Pickup
@onready var collHit = $GlobalSounds/CollHit

@onready var enemyHit = $EnemySounds/EnemyHit
@onready var bossShoot = $EnemySounds/BossShoot
@onready var nootNoot = $EnemySounds/NootNoot

@onready var pistol = $PlayerSounds/Pistol
@onready var rifle = $PlayerSounds/Rifle
@onready var shotgun = $PlayerSounds/Shotgun
@onready var melee = $PlayerSounds/Melee
@onready var playerHit = $PlayerSounds/PlayerHit
@onready var weaponSwitch = $PlayerSounds/WeaponSwitch
@onready var playerDeath = $PlayerSounds/PlayerDeath

@onready var preWave = $StreamPlayer/PreWave
@onready var startWave = $StreamPlayer/StartWave
@onready var finalWave = $StreamPlayer/FinalWave
@onready var lose = $StreamPlayer/Lose
@onready var win = $StreamPlayer/Win
@onready var mainMenu = $StreamPlayer/MainMenu
@onready var bomb = $StreamPlayer/Bomb

var gunSounds : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	gunSounds = [pistol, rifle, shotgun, melee] # Replace with function body.

