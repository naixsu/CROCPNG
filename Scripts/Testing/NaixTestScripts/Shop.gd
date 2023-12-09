extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.show_shop.rpc()
		body.hide_ready.rpc()
	

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		body.hide_shop.rpc()
		body.show_ready.rpc()
