extends Area2D

export var speed = 1000

var _direction = Vector2(1, 0)

func _physics_process(delta):
	position += _direction.rotated(rotation) * delta * speed

func _on_Lifespan_timeout():
	call_deferred("queue_free")


func _on_Laser_body_entered(body):
	if body.has_method("destroy"):
		body.destroy()
