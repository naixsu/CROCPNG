extends Node2D

@onready var indicator = $Indicator

var parent : Enemy

func _ready():
	pass

func _physics_process(delta):
	
	if parent.hasBomb:
		var canvas = get_canvas_transform() 
		var topLeft = -canvas.origin / canvas.get_scale()
		var size = get_viewport_rect().size / canvas.get_scale()
		
		set_pos(Rect2(topLeft, size), Vector2(20, 20))
	else:
		hide()
#		set_the_rotation()

func set_pos(bounds, offset):
	indicator.global_position.x = clamp(
		global_position.x, 
		bounds.position.x + offset.x, 
		bounds.end.x - offset.x
	)
	
	indicator.global_position.y = clamp(
		global_position.y, 
		bounds.position.y + offset.y, 
		bounds.end.y - offset.y
	)
	
	if bounds.has_point(global_position):
		hide()
	else:
		show()

func initialize(parent):
	self.parent = parent
