extends Node2D

signal upgrade(subject, stat)

@onready var health = $TabContainer/Player/Health
@onready var speed = $TabContainer/Player/Speed
@onready var dash = $TabContainer/Player/Dash




func _process(delta):
	if health.get_node("ProgressBar").value == 100:
		health.get_node("HealthButton").visible = false
	if speed.get_node("ProgressBar").value == 100:
		speed.get_node("SpeedButton").visible = false 
	if dash.get_node("ProgressBar").value == 100:
		dash.get_node("DashButton").visible = false
		
# Player
func _on_health_button_pressed():
	upgrade.emit("player", "health")
func _on_speed_button_pressed():
	upgrade.emit("player", "speed")
func _on_dash_button_pressed():
	upgrade.emit("player", "dash")

# Pistol
func _on_p_dmg_button_pressed():
	upgrade.emit("pistol", "damage")
func _on_p_acc_button_pressed():
	upgrade.emit("pistol", "accuracy")
func _on_pbs_button_pressed():
	upgrade.emit("pistol", "bulletSpeed")

# Rifle
func _on_r_dmg_button_pressed():
	upgrade.emit("rifle", "damage")
func _on_r_acc_button_pressed():
	upgrade.emit("rifle", "accuracy")
func _on_rbs_button_pressed():
	upgrade.emit("rifle", "bulletSpeed")

# Shotgun
func _on_s_dmg_button_pressed():
	upgrade.emit("shotgun", "damage")
func _on_s_acc_button_pressed():
	upgrade.emit("shotgun", "accuracy")
func _on_sbs_button_pressed():
	upgrade.emit("shotgun", "bulletSpeed")
