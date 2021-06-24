extends Node

export (Array, PackedScene) var spaceships

var client_name
var client_id
var client_spaceship_index

func _ready():
	randomize()
	client_name = str(randi() % 255)
	client_spaceship_index = randi() % spaceships.size()
	
func get_info():
	return {
		"name": client_name,
		"spaceship_index": client_spaceship_index,
	}

