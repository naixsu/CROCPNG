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
@onready var playerRespawn = $PlayerSounds/PlayerRespawn
@onready var playerDash = $PlayerSounds/PlayerDash

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

@rpc("any_peer", "call_local")
func play_sound(sound : AudioStreamPlayer) -> void:
	print("Playing " + str(sound))
	sound.play()

@rpc("any_peer", "call_local")
func stop_sound(sound : AudioStreamPlayer) -> void:
	print("Stopping " + str(sound))
	sound.stop()

@rpc("any_peer", "call_local")
func play_pre_wave():
	preWave.play()
	
@rpc("any_peer", "call_local")
func stop_pre_wave():
	preWave.stop()

@rpc("any_peer", "call_local")
func play_start_wave():
	startWave.play()
	
@rpc("any_peer", "call_local")
func stop_start_wave():
	startWave.stop()

@rpc("any_peer", "call_local")
func play_final_wave():
	finalWave.play()
	
@rpc("any_peer", "call_local")
func stop_final_wave():
	finalWave.stop()

@rpc("any_peer", "call_local")
func play_noot_noot():
	nootNoot.play()
	
@rpc("any_peer", "call_local")
func stop_noot_noot():
	nootNoot.stop()

@rpc("any_peer", "call_local")
func play_win():
	win.play()

@rpc("any_peer", "call_local")
func play_lose():
	lose.play()
