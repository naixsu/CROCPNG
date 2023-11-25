extends CanvasLayer

@onready var playerReadyCount = $PlayerReadyCount
@onready var waveNotif = $WaveNotif
@onready var waveCountdown = $WaveNotif/WaveCountdown
#@onready var players = GameManager.players # init player dict

@export var readyCount : int = 0

var showReady : bool = true
var startCountdown : bool = false
var displayCountdown : bool = false

signal toggle_ready
signal start_wave

func _on_ready_button_button_down():
#	ready_up.rpc()
	ready_up()

func _physics_process(delta):
	update_ready_count()
	
	if startCountdown: 
		waveCountdown.start()
		waveNotif.show()
		displayCountdown = true
	
	if displayCountdown: 
		display_countdown()
	
	
func display_countdown():
	startCountdown = false
	waveNotif.text = "Wave Starts In: %0.1fs" % waveCountdown.time_left
	
#@rpc("any_peer")
func update_ready_count():
	readyCount = 0
	# Get all players in the tree
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		if player.readyState == true: 
			readyCount += 1
#	var players = GameManager.players
#	for player in players:
#		if players[player].readyState: readyCount += 1
	
	var text = "Number of Players Ready: {0}/{1}".format({
		"0": str(readyCount),
		"1": GameManager.players.size()
	})

	playerReadyCount.text = text
	
	check_all_ready()

func check_all_ready():
	if readyCount == GameManager.players.size() and showReady:
		showReady = false
		startCountdown = true
		playerReadyCount.hide()
	
	

func ready_up():
	toggle_ready.emit()


func _on_wave_countdown_timeout():
	displayCountdown = false
	waveNotif.hide()
	start_wave.emit()
	
	reset_ready()

func reset_ready(): # Reset the readyState of all players
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		player.readyState = false
	
