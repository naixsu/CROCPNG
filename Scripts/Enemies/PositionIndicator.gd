extends Node2D

@onready var indicator = $Indicator

var camera
var viewportCenter
var parent : Enemy

func _ready():
	camera = get_viewport().get_camera_2d()
	viewportCenter = Vector2(get_viewport().size) / 2

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
	var clamped_position = Vector2(
		clamp(global_position.x, bounds.position.x + offset.x, bounds.end.x - offset.x),
		clamp(global_position.y, bounds.position.y + offset.y, bounds.end.y - offset.y)
	)
	
	indicator.global_position = clamped_position
	
	if bounds.has_point(global_position):
		hide()
	else:
		show()

func set_the_rotation():
	var angle = (global_position-indicator.global_position).angle()
	indicator.global_rotation = angle

func initialize(parent):
	self.parent = parent

