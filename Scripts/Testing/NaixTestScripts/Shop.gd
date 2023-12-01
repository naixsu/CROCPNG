extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		print("Player is colliding")
		body.get_node("Shop").visible = true
	

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		print("Player is exiting")
		body.get_node("Shop").visible = false
