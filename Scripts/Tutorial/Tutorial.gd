extends Control

var panels : Array
var currentPanelIndex : int

signal back_to_main
signal from_tutorial_next_prev_clicked

func _ready():
	panels = [$Movement, $Attack, $Weapon, $Zoom, $Shop]
	# Initialize panels' visibility
	for i in range(1, panels.size()):
		panels[i].visible = false

	currentPanelIndex = 0  # Set the initial visible panel to Movement
	panels[0].visible = true
	
	
#"Next" button
func _on_next_pressed():
	panels[currentPanelIndex].visible = false
	currentPanelIndex += 1
	if currentPanelIndex >= panels.size():
		currentPanelIndex = 0
		
	panels[currentPanelIndex].visible = true
	
	from_tutorial_next_prev_clicked.emit()
	
#"Previous" button
func _on_prev_pressed():
	panels[currentPanelIndex].visible = false
	currentPanelIndex -= 1	
	if currentPanelIndex < 0:
		currentPanelIndex = panels.size() - 1

	panels[currentPanelIndex].visible = true
	from_tutorial_next_prev_clicked.emit()


func _on_main_menu_pressed():
	back_to_main.emit()
