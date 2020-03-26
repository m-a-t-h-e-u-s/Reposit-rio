extends Node2D

var SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(position.x < -1280):
		queue_free()
	else:
		position = Vector2(position.x - SPEED * delta, position.y)
