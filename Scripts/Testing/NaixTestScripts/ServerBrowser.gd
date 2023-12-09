extends Control

signal foundServer(ip, port, roomInfo)
signal updateServer(ip, port, roomInfo)
signal joinGame(ip)
signal hide_host

@onready var SoundManager = $"../SoundManager"
@onready var vBoxContainer = $Panel/VBoxContainer

var broadcastTimer : Timer

var roomInfo = {"name":"name", "playerCount": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
@export var broadcastAddress : String = "255.255.255.255"


@export var ServerInfo : PackedScene

var ip : String
# Called when the node enters the scene tree for the first time.
func _ready():
	broadcastTimer = $BroadcastTimer

	# Might want to optimize `broadcastAddress` 
	# to work with the device's IP addresses.
	# But for now, 255.255.255.255 will do
	print("BroadcastAddress: " + str(broadcastAddress))

func set_up():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listenPort)
	if ok == OK:
		print("Bound to Listen Port " + str(listenPort) + " Successful")
		$Label.text = "Bound to listen port: true"
	else:
		print("Failed to bind to Listen Port!")
		$Label.text = "Bound to listen port: false"

# Setup Broadcast
func set_up_broadcast(roomName):
	roomInfo.name = roomName
	roomInfo.playerCount = GameManager.players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	
	if ok == OK:
		print("Bound to Broadcast Port " + str(broadcastPort) + " at " + str(broadcastAddress) + " Successful")
	else:
		print("Failed to bind to Broadcast Port!")
		
	broadcastTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if listener == null:
		return
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii()
		var currentRoomInfo = JSON.parse_string(data)

		for i in $Panel/VBoxContainer.get_children():
			if i.name == currentRoomInfo.name:
				updateServer.emit(serverip, serverport, currentRoomInfo)
				i.get_node("IP").text = str(serverip)
				i.get_node("PlayerCount").text = str(currentRoomInfo.playerCount)
				
				if i.get_node("IP").text != "":
					i.joinButton.visible = true
				return

		var currentInfo = ServerInfo.instantiate()
		currentInfo.name = currentRoomInfo.name
		currentInfo.get_node("Name").text = currentRoomInfo.name
		currentInfo.get_node("IP").text = str(serverip)
		currentInfo.get_node("PlayerCount").text = str(currentRoomInfo.playerCount)
		
		$Panel/VBoxContainer.add_child(currentInfo)
		currentInfo.joinGame.connect(join_by_ip)
		foundServer.emit(serverip, serverport, currentRoomInfo)
			

func _on_broadcast_timer_timeout():
	roomInfo.playerCount = GameManager.players.size()
	var data = JSON.stringify(roomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

	
func clean_up():
	print("Cleaning Up")
	if listener != null:
		listener.close()
	broadcastTimer.stop()
	
	if broadcaster != null:
		broadcaster.close()

func _exit_tree():
	clean_up()

func join_by_ip(joinIP):
	joinGame.emit(joinIP)
	
func _on_find_server_button_down():
	SoundManager.click.play()
	hide_host.emit()
	set_up() # Replace with function body.
