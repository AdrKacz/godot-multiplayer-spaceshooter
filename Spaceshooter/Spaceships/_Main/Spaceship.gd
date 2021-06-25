extends Node

# Signals
signal is_destroyed(spaceship)

# Spaceship
export (PackedScene) var SpaceshipController

# Aim
var _target = Vector2()
puppet var puppet_target = Vector2()

# Information
var _is_destroyed = true

# Reference to Nodes
var _spaceship
var _laser_position
onready var _lasers = $Lasers
onready var _shoot_cool_down = $ShootCoolDown

func _ready():
	# Instance Spaceship
	_spaceship = SpaceshipController.instance()
	_spaceship.set_name("SpaceshipController")
	_laser_position = _spaceship.get_node("LaserPosition")
#	Link to signal
	if is_network_master():
		_spaceship.connect("is_destroyed", self, "destroy")
		emit_signal("is_destroyed", self)
	else:
		rpc("call_for_initialisation")
	
remotesync func show_spaceship(initial_position, initial_rotation):
	# Initialise position
	_spaceship.position = initial_position
	_spaceship.rotation = initial_rotation
	# Initialise target
	_target = _spaceship.position
	if is_network_master():
		rset("puppet_target", _target)
	# Show spaceship
	add_child(_spaceship)
	_is_destroyed = false
	
puppet func initialise_spaceship(initial_is_destroyed, initial_position, initial_rotation):
	if not initial_is_destroyed:
		show_spaceship(initial_position, initial_rotation)
		
master func call_for_initialisation():
	rpc("initialise_spaceship", _is_destroyed, _spaceship.position, _spaceship.rotation)

# Get target and shoot (spawning reinitialise target: need mouse movement for first move)
func _input(event):
#	Take input only if master or not destroyed
	if not is_network_master() or _is_destroyed:
		return
	# Mouse in viewport coordinates
	if event is InputEventMouseButton:
		if event.is_pressed():
			rpc("trigger_shoot", true)
		else:
			rpc("trigger_shoot", false)
	elif event is InputEventMouseMotion:
		_target = event.position
		rset("puppet_target", _target)
		
func _physics_process(delta):
#	Move spaceship
	if _is_destroyed:
		return
		
#	Set target if puppet
	if not is_network_master():
		_target = puppet_target
	
#	Move spaceship toward target
	_spaceship.spaceship_move_toward(_target, delta)
	
remotesync func trigger_shoot(trigger):
	if trigger:
		shoot_laser()
		_shoot_cool_down.start()
	else:
		_shoot_cool_down.stop()
	
func shoot_laser():
	var laser = _spaceship.laser.instance()
	laser.global_position = _laser_position.global_position
	laser.rotation = _spaceship.rotation
	_lasers.add_child(laser)
	
func _on_ShootCoolDown_timeout():
	shoot_laser()
	
remotesync func destroy_spaceship():
	remove_child(_spaceship)
	_is_destroyed = true
	
master func destroy():
	rpc("trigger_shoot", false)
	rpc("destroy_spaceship")
	emit_signal("is_destroyed", self)
