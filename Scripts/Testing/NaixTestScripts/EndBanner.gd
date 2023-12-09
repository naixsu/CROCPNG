extends CanvasLayer

signal restart_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()

# restart_game will essentially go to main menu
# no actual "restart" on a wave rn
# coz too many variables to reset
func _on_menu_button_pressed():
	restart_game.emit()
