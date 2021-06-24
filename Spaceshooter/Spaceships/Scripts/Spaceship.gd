extends KinematicBody2D

signal is_destroyed

export (PackedScene) var laser

func destroy(): # Need to work on dead/respawn in depth
	emit_signal("is_destroyed")
