extends Control

signal foundServer(ip, port, roomInfo)
signal updateServer(ip, port, roomInfo)
signal joinGame(ip)

var broadcastTimer : Timer

var roomInfo = {"name":"name", "playerCount": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
#@export var broadcastAddress : String = "192.168.1.255"
#@export var broadcastAddress : String = "255.255.255.255"
#@export var broadcastAddress : String = "172.16.0.255"
@export var broadcastAddress : String

@export var ServerInfo : PackedScene
@onready var SoundManager = $"../SoundManager"
var ip : String
# Called when the node enters the scene tree for the first time.
func _ready():
	broadcastTimer = $BroadcastTimer
#	set_up()

#	Comment out for windows	
#	var ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	print("test")
	if OS.has_feature("windows"):
		ip =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("x11"):
		ip =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("macos"):
		ip = IP.resolve_hostname("localhost", 1)
	print("Local IP: " + str(ip))
	var ipOctets = ip.split(".")
	ipOctets[2] = "1"
	ipOctets[3] = "255"
	var modifiedIP = str(ipOctets[0] + "." + ipOctets[1] + "." + ipOctets[2] + "." + ipOctets[3])
#	print(modifiedIP)
	broadcastAddress = str(modifiedIP)
	
	print("BroadcastAddress: " + str(broadcastAddress))
	
	pass # Replace with function body.
	

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
func set_up_broadcast(name):
	roomInfo.name = name
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
func _process(delta):
	if listener == null:
		return
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii()
		var roomInfo = JSON.parse_string(data)
		
#		print(
#			"Server IP: {0} Server Port: {1} Room Info: {2}"
#			.format({
#				"0": serverip,
#				"1": str(serverport),
#				"2": str(roomInfo)
#			})
#		)
		

		for i in $Panel/VBoxContainer.get_children():
			if i.name == roomInfo.name:
				updateServer.emit(serverip, serverport, roomInfo)
				i.get_node("IP").text = str(serverip)
				i.get_node("PlayerCount").text = str(roomInfo.playerCount)
				return

		var currentInfo = ServerInfo.instantiate()
		currentInfo.name = roomInfo.name
		currentInfo.get_node("Name").text = roomInfo.name
		currentInfo.get_node("IP").text = str(serverip)
		currentInfo.get_node("PlayerCount").text = str(roomInfo.playerCount)
		
		$Panel/VBoxContainer.add_child(currentInfo)
#		connect(currentInfo.joinGame, joinByIP)
		currentInfo.joinGame.connect(join_by_ip)
		foundServer.emit(serverip, serverport, roomInfo)
			

func _on_broadcast_timer_timeout():
#	print("Broadcasting Game")
	roomInfo.playerCount = GameManager.players.size()
	var data = JSON.stringify(roomInfo)
	var packet = data.to_ascii_buffer()
#	print(roomInfo.playerCount)
	broadcaster.put_packet(packet)
	# print("Number of enemies: " + str(GameManager.enemyCount))
	pass # Replace with function body.
#
#	print("Broadcasting Game")
	
	

func clean_up():
	if listener != null:
		listener.close()
	broadcastTimer.stop()
	
	if broadcaster != null:
		broadcaster.close()

func _exit_tree():
	clean_up()

func join_by_ip(ip):
	joinGame.emit(ip)


func _on_find_server_button_down():
	SoundManager.click.play()
	set_up() # Replace with function body.
