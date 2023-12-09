extends HBoxContainer
@onready var SoundManager = $SoundManager
@onready var joinButton = $JoinButton

signal joinGame(ip)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_join_button_button_down():
	SoundManager.click.play()
	joinButton.disabled = true
	joinGame.emit($IP.text)
	pass # Replace with function body.
