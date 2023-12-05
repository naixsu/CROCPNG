extends CanvasLayer


@onready var healthBar = $HealthBar
@onready var playerIcon = $PlayerIcon
@onready var hotBar = $HotBar
@onready var moneyAnim = $MoneyAnim
@onready var moneyText = $MoneyText


# Called when the node enters the scene tree for the first time.
func _ready():
	moneyAnim.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
