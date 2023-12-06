extends CanvasLayer


@onready var healthBar = $PlayerStats/HealthAndMoneyContainer/Details/HealthContainer/HealthBar
@onready var playerIcon = $PlayerStats/PlayerIcon
@onready var hotBar = $HotBar
@onready var moneyAnim = $PlayerStats/HealthAndMoneyContainer/Details/Money/MoneyAnim
@onready var moneyText = $PlayerStats/HealthAndMoneyContainer/Details/Money/MoneyText
@onready var pistolButton = $HotBar/HBoxContainer/PistolButton
@onready var rifleButton = $HotBar/HBoxContainer/RifleButton
@onready var shotgunButton = $HotBar/HBoxContainer/ShotgunButton
@onready var meleeButton = $HotBar/HBoxContainer/MeleeButton

var hotBarButtons : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	moneyAnim.play("default")
	# The order matters
	hotBarButtons = [pistolButton, rifleButton, shotgunButton, meleeButton]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
