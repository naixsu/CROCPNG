extends Control

@export var address = "127.0.0.1"
@export var port = 8910
@export var maxPlayers = 4
@export var maxCharLimit = 10
@export var PlayerLogs : PackedScene

@onready var nameEdit = $NameEdit
@onready var SoundManager = $SoundManager # Capitalizing this
@onready var startGame = $StartGame
@onready var tutorial = $Tutorial
@onready var tutorialButton = $TutorialButton
@onready var findServer = $FindServer
@onready var host = $Host
@onready var serverBrowser = $ServerBrowser
@onready var serverInfoHeading = $ServerBrowser/Panel/ServerInfoHeading
@onready var serverVBoxContainer = $ServerBrowser/Panel/VBoxContainer

# Deprecated
#@onready var line_edit = $LineEdit
#@onready var addressEdit = $Address

var peer
var ipAddress = ""
var serverName = ""
var isHost = false

# Called when the node enters the scene tree for the first time.
func _ready():
	nameEdit.max_length = maxCharLimit
	SoundManager.mainMenu.play()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	serverBrowser.connect("hide_host", hide_host)
	tutorial.connect("back_to_main", back_to_main)
	tutorial.connect("from_tutorial_next_prev_clicked", from_tutorial_next_prev_clicked)
	
	# TODO:
	# work on this so that it only works for server
	# or deprecate
#	if OS.has_feature("windows"):
#		if OS.has_environment("COMPUTERNAME"):
#			ipAddress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
#
#	line_edit.text = ipAddress
	
#	if "--server" in OS.get_cmdline_args():
#		host_game()
	if "--server" in OS.get_cmdline_args():
		var serverIndex = OS.get_cmdline_args().find("--server")
		serverName = OS.get_cmdline_args()[serverIndex + 1]
		custom_host(serverName)

	$ServerBrowser.joinGame.connect(join_by_ip)
	pass # Replace with function body.



# Gets called on the server and clients
func peer_connected(id):
	print("Player connected: " + str(id))
	
	if isHost:
		var playerLogs = PlayerLogs.instantiate()
		playerLogs.name = str(id)
		playerLogs.get_node("Log").text = "Player connected : " + str(id)
		serverVBoxContainer.add_child(playerLogs)
	
# Gets called on the server and clients
func peer_disconnected(id):
	print("Player disconnected: " + str(id))
	
	if isHost:
		var playerLogs = PlayerLogs.instantiate()
		playerLogs.name = str(id)
		playerLogs.get_node("Log").text = "Player disconnected : " + str(id)
		serverVBoxContainer.add_child(playerLogs)
	
	GameManager.players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

# Called only from clients
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, nameEdit.text, multiplayer.get_unique_id())

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"readyState": false
			# other: other
		}
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)

# Called only from clients
func connection_failed():
	print("Connection failed")
	

func host_game():
	isHost = true
	serverInfoHeading.hide()
	findServer.hide()
	host.hide()
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, maxPlayers)
	
	if error != OK:
		print("Cannot host: " + str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Make sure to have the same compression
	multiplayer.set_multiplayer_peer(peer)
#	print("Waiting for players. Hosted at: " + ipAddress)
	$ServerBrowser.set_up_broadcast(nameEdit.text + "'s server")
	startGame.show()
	# send_player_information(nameEdit.text, multiplayer.get_unique_id())

func custom_host(serverName):
	isHost = true
	serverInfoHeading.hide()
	findServer.hide()
	host.hide()
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, maxPlayers)
	
	if error != OK:
		print("Cannot host: " + str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Make sure to have the same compression
	multiplayer.set_multiplayer_peer(peer)
	$ServerBrowser.set_up_broadcast(serverName + "'s server")
	startGame.show()

func _on_host_button_down():
	SoundManager.click.play()
	host_game()
	send_player_information(nameEdit.text, multiplayer.get_unique_id())
	$ServerBrowser.set_up_broadcast($NameEdit.text + "'s server")
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	# Deprecated
#	var ip = addressEdit.text
#	print("IP: " + ip)
#	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.

func join_by_ip(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	startGame.show()


@rpc("any_peer", "call_local") # anyone can call this. maybe try only the host can click start
func start_game():
	var scene = load("res://Scenes/Testing/NaixTestScenes/TestMultiplayerScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	SoundManager.mainMenu.stop()
	

func _on_start_game_button_down():
	SoundManager.click.play()
	start_game.rpc()
	startGame.hide()
	findServer.show()
	host.show()
	serverInfoHeading.show()
	pass # Replace with function body.


func _on_button_button_down():
	GameManager.players[GameManager.players.size() + 1] = {
		"name": "test",
		"id": 1, # host ID
		"readyState": false
	}
	pass # Replace with function body.


func _on_exit_game_button_down():
	SoundManager.click.play()
	get_tree().quit()


func _on_name_edit_text_changed(new_text):
#	SoundManager.type.set_pitch_scale(randf_range(0.4, 0.5))
	SoundManager.type.play()
	# if new_text.length() > maxCharLimit:
	# 	return


func _on_tutorial_button_pressed():
	SoundManager.click.play()
	tutorialButton.hide()
	tutorial.show()

func back_to_main():
	SoundManager.click.play()
	tutorial.hide()
	tutorialButton.show()

func from_tutorial_next_prev_clicked():
	SoundManager.click.play()

func restart():
	print("Restarting Game")
	var root = get_tree().get_root()
	var testMultiplayerScene = root.get_node("TestMultiplayerScene")
	
#	var players = get_tree().get_nodes_in_group("Player")
#	for i in players:
#		i.queue_free()
	testMultiplayerScene.queue_free()
	$ServerBrowser.clean_up()
	reset_game_manager()
	clear_server_info()
#	multiplayer.queue_free()
	peer.close()
#	peer = null
	self.show()

func reset_game_manager():
	GameManager.players = {}
	GameManager.wave = 0
	GameManager.finalWave = false
	GameManager.gameOver = false
	GameManager.enemyCount = 0

func clear_server_info():
	for panel in $ServerBrowser.vBoxContainer.get_children():
		panel.queue_free()

func hide_host():
	findServer.hide()
	host.hide()
