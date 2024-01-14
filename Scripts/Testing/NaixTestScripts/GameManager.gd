# Autoloaded in Project > Project Settings > Autoload
# Makes this script global, kinda like an instance in Unity
extends Node

var players = {}
var wave = 0
var finalWave = false
var gameOver = false
var enemyCount = 0

@export var maxWave = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
