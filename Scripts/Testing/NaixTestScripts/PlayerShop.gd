extends Node2D

class_name Shop

signal upgrade(subject, stat)

@onready var health = $TabContainer/Player/Health
@onready var speed = $TabContainer/Player/Speed
@onready var dash = $TabContainer/Player/Dash

@onready var pDamage = $TabContainer/Pistol/Damage
@onready var pAccuracy = $TabContainer/Pistol/Accuracy
@onready var pBulletspeed = $TabContainer/Pistol/Bulletspeed

@onready var rDamage = $TabContainer/Rifle/Damage
@onready var rAccuracy = $TabContainer/Rifle/Accuracy
@onready var rBulletspeed = $TabContainer/Rifle/Bulletspeed

@onready var sDamage = $TabContainer/Shotgun/Damage
@onready var sAccuracy = $TabContainer/Shotgun/Accuracy
@onready var sBulletspeed = $TabContainer/Shotgun/Bulletspeed


var playerHealthCost = 25
var playerSpeedCost = 40
var playerDashCost = 250

var pistolDmgCost = 25
var pistolAccCost = 15
var pistolBSCost = 50

var rifleDmgCost = 40
var rifleAccCost = 30
var rifleBSCost = 50

var shotgunDmgCost = 30
var shotgunAccCost = 50
var shotgunBSCost = 60



func _process(delta):
	if health.get_node("ProgressBar").value == 100:
		health.get_node("HealthButton").visible = false
	if speed.get_node("ProgressBar").value == 100:
		speed.get_node("SpeedButton").visible = false 
	if dash.get_node("ProgressBar").value == 100:
		dash.get_node("DashButton").visible = false
	
	if pDamage.get_node("ProgressBar").value == 100:
		pDamage.get_node("PDmgButton").visible = false
	if pAccuracy.get_node("ProgressBar").value == 100:
		pAccuracy.get_node("PAccButton").visible = false
	if pBulletspeed.get_node("ProgressBar").value == 100:
		pBulletspeed.get_node("PBSButton").visible = false
	
	if rDamage.get_node("ProgressBar").value == 100:
		rDamage.get_node("RDmgButton").visible = false
	if rAccuracy.get_node("ProgressBar").value == 100:
		rAccuracy.get_node("RAccButton").visible = false
	if rBulletspeed.get_node("ProgressBar").value == 100:
		rBulletspeed.get_node("RBSButton").visible = false
	
	if sDamage.get_node("ProgressBar").value == 100:
		pDamage.get_node("SDmgButton").visible = false
	if sAccuracy.get_node("ProgressBar").value == 100:
		pAccuracy.get_node("SAccButton").visible = false
	if sBulletspeed.get_node("ProgressBar").value == 100:
		pBulletspeed.get_node("SBSButton").visible = false

		
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
