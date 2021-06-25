extends KinematicBody2D

signal is_destroyed

# Spaceshipt Control
export var max_speed = 800
export var min_speed = 100
export var acceleration_base = 80
export var acceleration_multiplicator = 10
export var angular_acceleration_base = 1
export var angular_acceleration_multiplicator = 10

export var break_multiplicator = 0.5

# Information
var _speed = min_speed

export (PackedScene) var laser

func destroy(): # Need to work on dead/respawn in depth
	emit_signal("is_destroyed")
	
# Movement logic
func spaceship_move_toward(target, delta):
#	Get angle
	var angle_to_target = get_angle_to(target)	
	
#	Speed
	var cos_angle = cos(angle_to_target)
	var sin_angle = sin(angle_to_target)
	var desired_speed = min_speed + (cos_angle * 0.5 + 0.5) * (max_speed - min_speed)
	var speed_percentage = (_speed - min_speed) / (max_speed - min_speed)
	
	var current_break_multiplicator = break_multiplicator if desired_speed < _speed else 1
	
	var acceleration = acceleration_base * (1 + current_break_multiplicator * acceleration_multiplicator * speed_percentage)
	
	_speed = move_toward(_speed, desired_speed, acceleration * delta)
	
#	Rotate
	var angular_acceleration = angular_acceleration_base * (1 + angular_acceleration_multiplicator * (1 - speed_percentage))
	set_rotation(move_toward(rotation, rotation + angle_to_target, angular_acceleration * delta))
	
#	Move forward
	var velocity = transform.x.normalized() * _speed
	move_and_slide(velocity)
