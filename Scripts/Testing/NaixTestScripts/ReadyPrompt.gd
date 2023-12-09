###
#
# Also treating this as a gamestate.
#
###

extends CanvasLayer

@onready var playerReadyCount = $PlayerReadyCount
@onready var waveNotif = $WaveNotif
@onready var waveCountdown = $WaveNotif/WaveCountdown
@onready var bg = $BG
@onready var readyButton = $PlayerReadyCount/ReadyButton

@export var readyCount : int = 0

var showReady : bool = true
var startCountdown : bool = false
var displayCountdown : bool = false
var checkForEnemies : bool = false
var readyClicked : bool = false
var rewardCalled: bool = false

signal toggle_ready
signal start_wave
signal reward_players
signal win_banner
signal pre_wave

func _on_ready_button_button_down():
#	ready_up.rpc()
	ready_up()
	

func _physics_process(delta):
	if showReady:
		bg.show()
		update_ready_count()
	
	if startCountdown: 
		waveCountdown.start()
		waveNotif.show()
		displayCountdown = true
	
	if displayCountdown: 
		display_countdown()
	
	if checkForEnemies:
		await get_tree().create_timer(1).timeout
		if GameManager.finalWave and GameManager.enemyCount == 0:
			print("\nNo more enemies and Final Wave\n")
			checkForEnemies = false
			win_banner.emit()
		elif GameManager.enemyCount == 0:
			print("\nNo more enemies\n")
			checkForEnemies = false
			showReady = true
			playerReadyCount.show()
			pre_wave.emit()
			if !rewardCalled:
				reward_players.emit()
				rewardCalled = !rewardCalled
			
	
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
		await get_tree().physics_frame
		if last_check_ready():
			showReady = false
			startCountdown = true
			playerReadyCount.hide()
	
func last_check_ready():
	var count = 0
	var players = get_tree().get_nodes_in_group("Player")
	
	for player in players:
		if player.readyState == true: 
			count += 1
	
	if count == GameManager.players.size():
		return true
	
	return false

func ready_up():
	toggle_ready.emit()
	readyClicked = !readyClicked
	
	update_ready_text()


func _on_wave_countdown_timeout():
	displayCountdown = false
	waveNotif.hide()
	bg.hide()
	start_wave.emit()
#	if GameManager.wave > 1:
#		reward_players.emit()
	rewardCalled = false
	reset_ready()

func reset_ready(): # Reset the readyState of all players
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		player.readyState = false
	checkForEnemies = true
	readyClicked = false
	
	update_ready_text()

func update_ready_text():
	# Toggle the ready button
	if readyClicked:
		readyButton.text = "Unready"
	else:
		readyButton.text = "Ready"
	
