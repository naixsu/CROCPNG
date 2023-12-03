extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_bullet

func _spawn_bullet(data):
	# position
	# bulletSpeed
	# Damage
	# direction
	var bulletScenePath = "res://Scenes/Bullet/BossBulletCB.tscn"
	var bullet = load(bulletScenePath).instantiate()
	bullet.global_position = data[0]
	bullet.speed = data[1]
	bullet.damage = data[2]
	bullet.direction = data[3]
	bullet.set_timer(data[4])
	
	return bullet
