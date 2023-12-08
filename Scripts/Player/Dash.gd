extends Node2D

@onready var timer = $DashTimer
@onready var dashCooldown = $DashCooldown

func start_dash(duration):
	timer.wait_time = duration
	timer.start()
	
	start_cd()

func start_cd():
	dashCooldown.start()
	
func is_dashing():
	return !timer.is_stopped()
	
