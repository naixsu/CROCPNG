extends Node2D

func handle_bullet_spawned(bullet: Bullet, pos, dir):
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(dir)

