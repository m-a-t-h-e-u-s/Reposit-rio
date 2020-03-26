extends KinematicBody2D

export (int) var run_speed = 200
export (int) var jump_speed = -400
export (int) var gravity = 800
export (int) var friction = 90

var jumping = false
var hooking = false
var lowered = false
var rasteira = false
var shot = false

var velocity = Vector2()
var Posi_Esquerdo = Vector2()
var Posi_Direito = Vector2()
var Posi_rel = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	var norma
	if (event is InputEventMouseButton):
		var Posi_player = get("position")
		if (event.button_index == BUTTON_LEFT and event.pressed):
			Posi_Esquerdo = event.position
			Posi_rel = Posi_Esquerdo - Posi_player
			norma = sqrt((Posi_rel[0] * Posi_rel[0]) + (Posi_rel[1] * Posi_rel[1]))
			Posi_rel = Posi_rel / norma
			shot = true
			if Posi_rel[0] > 0:
				$Gancho.rotation_degrees = -90 + atan((Posi_rel[1] / Posi_rel[0])) * 180 / PI
			else:
				$Gancho.rotation_degrees = 90 + atan((Posi_rel[1] / Posi_rel[0])) * 180 / PI
	else:
		shot = false
		hooking = false
		Posi_Direito = Vector2()
		Posi_Esquerdo = Vector2()
		
func _physics_process(delta):
	if shot == true:
		if len($Gancho.get_overlapping_bodies()) == 1:
			$Gancho/CollisionShape2D.scale.y += 1
		else:
			shot = false
			hooking = true
			
	if (hooking == false):
		gravity = 800
		if shot == false:
			Posi_Direito = Vector2()
			Posi_Esquerdo = Vector2()
			if $Gancho/CollisionShape2D.scale.y > 1:
				$Gancho/CollisionShape2D.scale.y = $Gancho/CollisionShape2D.scale.y * 0.5
		if (rasteira == false):
			velocity.x = 0
		else:
			if (velocity.x == 0):
				rasteira = false
			if (velocity.x > 0):
				velocity.x -= friction * delta
			else:
				velocity.x += friction * delta
	else:
		gravity = 0
		velocity.x = 400 * Posi_rel[0]
		velocity.y = 400 * Posi_rel[1]
		if $Gancho/CollisionShape2D.scale.y > 1:
			$Gancho/CollisionShape2D.scale.y -= 0.4 #0 * atan((Posi_rel[1] / Posi_rel[0]))
		else:
			velocity.y = 0
			velocity.x = 0
			$Gancho/CollisionShape2D.scale.y = 1
		
	if (Input.is_action_pressed("ui_up")) and (jumping == false):
		shot = false
		hooking = false
		jumping = true
		velocity.y = jump_speed
	if (is_on_floor()):
		jumping = false
		friction = 90
	else:
		friction = 0
	if (Input.is_action_pressed("ui_left")):
		hooking = false
		shot = false
		if (rasteira == false) and (lowered == false):
			velocity.x -= run_speed
			$AnimatedSprite2.flip_h = true
			$Collision.scale.y = 0.9
			$AnimatedSprite2.play("Run")
		if (Input.is_action_pressed("ui_down")):
			rasteira = true
			$Collision.position.y = 11
			$Collision.scale.y = 0.4
			$AnimatedSprite2.play("Rasteira")
			if (velocity.x > -50):
				rasteira = false
				lowered = true
				$Collision.position.y = 5
				$Collision.scale.x = 0.8
				$Collision.scale.y = 0.7
				$AnimatedSprite2.play("Abaixado")
	elif (Input.is_action_pressed("ui_right")):
		shot = false
		hooking = false
		if (rasteira == false) and (lowered == false):
			velocity.x += run_speed
			$AnimatedSprite2.flip_h = false
			$Collision.scale.y = 0.9
			$AnimatedSprite2.play("Run")
		if (Input.is_action_pressed("ui_down")):
			rasteira = true
			$Collision.position.y = 11
			$Collision.scale.y = 0.4
			$AnimatedSprite2.play("Rasteira")
			if (velocity.x < 50):
				rasteira = false
				lowered = true
				$Collision.position.y = 5
				$Collision.scale.x = 0.8
				$Collision.scale.y = 0.7
				$AnimatedSprite2.play("Abaixado")
	elif (Input.is_action_pressed("ui_down")):
		lowered = true
		rasteira = false
		shot = false
		$Collision.position.y = 5
		$Collision.scale.x = 0.8
		$Collision.scale.y = 0.7
		$AnimatedSprite2.play("Abaixado")
	else:
		$Collision.scale.x = 0.6
		$AnimatedSprite2.play("Idle")
		rasteira = false
		lowered = false
	velocity.y += delta * gravity

	velocity = move_and_slide(velocity, Vector2(0, -1))
