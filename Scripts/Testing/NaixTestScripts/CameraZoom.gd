extends Camera2D

@export var zoomMin = 0.4
@export var zoomMax = 1
@export var zoomFactor = 1.0
@export var zoomSpeed = 20

func _process(delta):
	zoom.x = lerp(zoom.x, zoom.x * zoomFactor, zoomSpeed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomFactor, zoomSpeed * delta)

	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)
