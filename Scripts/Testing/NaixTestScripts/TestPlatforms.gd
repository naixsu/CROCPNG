extends Node2D

@onready var SoundManager = $"../SoundManager"

func handle_hit():
	SoundManager.collHit.play()
