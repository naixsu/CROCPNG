extends CanvasLayer

@onready var timer = $Timer
@onready var label = $Label

var showWarning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if showWarning:
		var mapped_value = timer.time_left / timer.wait_time
		var modulate = lerp(1, 0, 1.0 - mapped_value)

		label.set_self_modulate(Color(1, 1, 1, modulate))

func warn():
	label.show()
	timer.start()
	showWarning = true

func _on_timer_timeout():
	showWarning = false
	label.set_self_modulate(Color(1, 1, 1, 0))
	label.hide()
