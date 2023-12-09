extends CanvasLayer

signal restart_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_button_pressed():
	get_tree().quit()

# No restart atm. Too many variables to reset :weary:
func _on_restart_button_pressed():
	restart_game.emit()
