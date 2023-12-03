extends MultiplayerSpawner


func _init():
	spawn_function = _spawn_bullet

func _spawn_bullet(data):
	# position
	# bulletSpeed
	# Damage
	# bullet rotation
	var bulletScenePath = "res://Scenes/Bullet/BulletCB.tscn"
	var bullet = load(bulletScenePath).instantiate()
	bullet.global_position = data[0]
	bullet.speed = data[1]
	bullet.damage = data[2]
	bullet.rotation_degrees = data[3]
	bullet.set_timer(data[4])
#	bullet.SoundManager.position = data[0]
	
	return bullet
