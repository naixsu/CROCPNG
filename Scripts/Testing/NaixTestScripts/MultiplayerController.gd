extends Control

@export var address = "127.0.0.1"
@export var port = 8910

@onready var nameEdit = $NameEdit

# Deprecated
#@onready var line_edit = $LineEdit
#@onready var addressEdit = $Address

var peer
var ipAddress = ""
var serverName = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
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
	
# Gets called on the server and clients
func peer_disconnected(id):
	print("Player disconnected: " + str(id))
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
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 32)
	
	if error != OK:
		print("Cannot host: " + str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Make sure to have the same compression
	multiplayer.set_multiplayer_peer(peer)
#	print("Waiting for players. Hosted at: " + ipAddress)
	$ServerBrowser.set_up_broadcast(nameEdit.text + "'s server")
	# send_player_information(nameEdit.text, multiplayer.get_unique_id())

func custom_host(serverName):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 32)
	
	if error != OK:
		print("Cannot host: " + str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Make sure to have the same compression
	multiplayer.set_multiplayer_peer(peer)
	$ServerBrowser.set_up_broadcast(serverName + "'s server")

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


@rpc("any_peer", "call_local") # anyone can call this. maybe try only the host can click start
func start_game():
	var scene = load("res://Scenes/Testing/NaixTestScenes/TestMultiplayerScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	

func _on_start_game_button_down():
	SoundManager.click.play()
	start_game.rpc()
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
