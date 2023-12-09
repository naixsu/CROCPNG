extends CanvasLayer


@onready var healthBar = $HealthBar
@onready var playerIcon = $PlayerIcon
@onready var hotBar = $HotBar
@onready var moneyAnim = $MoneyAnim
@onready var moneyText = $MoneyText
@onready var pistolButton = $HotBar/HBoxContainer/PistolButton
@onready var rifleButton = $HotBar/HBoxContainer/RifleButton
@onready var shotgunButton = $HotBar/HBoxContainer/ShotgunButton
@onready var meleeButton = $HotBar/HBoxContainer/MeleeButton
@onready var waveNumber = $VBoxContainer/WaveNumber
@onready var numberOfEnemies = $VBoxContainer/NumberOfEnemies

var hotBarButtons : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	moneyAnim.play("default")
	# The order matters
	hotBarButtons = [pistolButton, rifleButton, shotgunButton, meleeButton]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	waveNumber.text = "Wave Number %d / %d" % [GameManager.wave, GameManager.maxWave]
	numberOfEnemies.text = "Number of Enemies: %d" % [GameManager.enemyCount]
