extends Node2D

var isHeld : bool = false

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("detonate")

func _on_animated_sprite_2d_animation_finished():
	if multiplayer.is_server():
		queue_free()
		var root = get_tree().get_root()
		var multScene = root.get_node("TestMultiplayerScene")
		multScene.lose.rpc()
