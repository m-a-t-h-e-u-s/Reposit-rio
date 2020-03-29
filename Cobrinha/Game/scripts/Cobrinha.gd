extends KinematicBody2D
var x = false

var run_speed = 100
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _physics_process(delta):
	if x == true:
		if Input.is_action_pressed("ui_up"):
			$Cobrinha.position.y += 10
			x = false
		if Input.is_action_pressed("ui_down"):
			$Cobrinha.position.y -= 10
			x = false
	else:
		if Input.is_action_pressed("ui_right"):
			$Cobrinha.position.x += 10
			x = true
		if Input.is_action_pressed("ui_left"):
			$Cobrinha.position.x -= 10
			x = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
