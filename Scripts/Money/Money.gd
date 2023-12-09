extends Node2D

@export var value : int
@onready var anim = $AnimatedSprite2D
@onready var SoundManager = $SoundManager

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("idle")

# Collide with player
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("set_money"):
			body.set_money(self.value)
			if multiplayer.is_server():
				queue_free()
