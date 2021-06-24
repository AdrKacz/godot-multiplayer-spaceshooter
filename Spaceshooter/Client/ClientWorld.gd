extends Node2D

export (PackedScene) var Spaceship

onready var spawn_path = $Path2D/PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("connected", self, "_client_connected")
	Network.connect("disconnected", self, "_client_disconnected")


func _client_connected(id):
	print("Client Connected : ", id)
#	Add Client to the world
	var client = Spaceship.instance()
	
#	Register to Client signal
	client.connect("is_destroyed", self, "_client_destroyed")
	
#	Edit Client type
	client.SpaceshipController = Globals.spaceships[Network.peers_info[id].spaceship_index]
	client.set_name(str(id))
	client.set_network_master(id)
	
#	Add Client to tree
	add_child(client)

func _client_disconnected(id):
	print("Client Disconnected : ", id)
#	Add Client to the world
	var client = get_node_or_null(str(id))
	if client == null:
		return
	client.call_deferred("queue_free")
	
func _client_destroyed(client): # Only master of client call this function
	yield(get_tree().create_timer(1.0), "timeout")
	var spawn_position = get_spawn_position()
	client.rpc("show_spaceship", spawn_position.position, spawn_position.rotation)
	
	
func get_spawn_position():
	spawn_path.offset = randi()
	return {
		"position": spawn_path.position,
		"rotation": spawn_path.rotation + PI / 2,
	}
