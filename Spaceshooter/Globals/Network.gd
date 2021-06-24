extends Node

signal connected(id)
signal disconnected(id)

# The port we will listen to
export var PORT = 9080

# The URL we will connect to
export var websocket_url = "34.243.208.126"
#export var websocket_url = "127.0.0.1:9080"

# Peers Info
var peers_info = {}

# Our WebSocketClient instance
var _peer

func _set_server():
	if _peer != null:
		return
	_peer = WebSocketServer.new()
	# Start listening on the given port
	var err = _peer.listen(PORT, PoolStringArray(), true)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	else:
		print("Server listening on port ", PORT)
		get_tree().network_peer = _peer
	return
	
func _set_client():
	if _peer != null:
		return
	_peer = WebSocketClient.new()
	
	# Initiate connection to the given URL.
	var err = _peer.connect_to_url(websocket_url, PoolStringArray(), true)
	
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		print("Able to connect")
		get_tree().network_peer = _peer
	return

func _ready():
	if OS.has_feature("Server") or "--server" in OS.get_cmdline_args(): # remove --server in prod
		_set_server()
	else:
		_set_client()
		
	# Multiplayer API
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _peer_connected(id):
	print("[Client / Server] Peer [%s] connected" % id)
	rpc_id(id, "register_peer", Globals.get_info())
	
func _peer_disconnected(id):
	print("[Client / Server] Peer [%s] disconnected" % id)
	emit_signal("disconnected", id)
	
func _connected_ok():
	Globals.client_id = get_tree().get_network_unique_id()
	peers_info[Globals.client_id] = Globals.get_info()
	emit_signal("connected", Globals.client_id)
	print("[Client] Connection OK")
	
func _server_disconnected():
	print("[Client] Server disconnected")
	
func _connected_fail():
	print("[Client] Connection failed")
	
remote func register_peer(peer_info):
	print("[Client / Server] Register peer: ", peer_info)
	var id = get_tree().get_rpc_sender_id()
	if id != 1:
		peers_info[id] = peer_info
		emit_signal("connected", id)
	
func _process(_delta):
	if (get_tree().network_peer == null):
		return
		
	if get_tree().is_network_server() and not _peer.is_listening():
		return
		
	if not get_tree().is_network_server() and (
	_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED or
	_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		return
		
	_peer.poll()
	
