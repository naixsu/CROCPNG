extends MultiplayerSpawner

func _init():
	spawn_function = _spawn_money

func _spawn_money(data):
	var moneyScenePath = "res://Scenes/Money/Money.tscn"
	var money = load(moneyScenePath).instantiate()
	
	money.position = data[0]
	
	return money
