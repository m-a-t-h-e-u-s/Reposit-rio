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
var colisao = Vector2()
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
			
		
		if (event.button_index == BUTTON_RIGHT) and (event.pressed):
			Posi_Direito = event.position
			Posi_rel = Posi_Direito - Posi_player
			norma = sqrt((Posi_rel[0] * Posi_rel[0]) + (Posi_rel[1] * Posi_rel[1]))
			if (norma > 50) and (norma < 400):
				velocity.x = 400 * Posi_rel[0]/norma
				velocity.y = 400 * Posi_rel[1]/norma
				hooking = true
	
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
			colisao = $Gancho.get_position
			shot = false
			hooking = true
			
	if (hooking == false):
		gravity = 800
		if shot == false:
			Posi_Direito = Vector2()
			Posi_Esquerdo = Vector2()
			if $Gancho/CollisionShape2D.scale.y > 1:
				$Gancho/CollisionShape2D.scale.y = $Gancho/CollisionShape2D.scale.y * 0.5
#			$Gancho/CollisionShape2D.scale.y = 1
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
		
	var Posi_player = get("position")
	var Posi_rel_D = Posi_Direito - Posi_player
	var Posi_rel_E = colisao
	var norma_D = sqrt((Posi_rel_D[0] * Posi_rel_D[0]) + (Posi_rel_D[1] * Posi_rel_D[1]))
	var norma_E = sqrt((Posi_rel_E[0] * Posi_rel_E[0]) + (Posi_rel_E[1] * Posi_rel_E[1]))
	if(norma_D < 50) or (norma_E < 50):
		velocity.y = 0
		velocity.x = 0
		$Gancho/CollisionShape2D.scale.y = 1

		
	if (Input.is_action_pressed("ui_up")) and (jumping == false):
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
		if (rasteira == false) and (lowered == false):
			velocity.x -= run_speed
			$AnimatedSprite2.flip_h = true
			$AnimatedSprite2.play("Run")
		if (Input.is_action_pressed("ui_down")):
			rasteira = true
			$AnimatedSprite2.play("Rasteira")
			if (velocity.x > -50):
				rasteira = false
				lowered = true
				$AnimatedSprite2.play("Abaixado")
	elif (Input.is_action_pressed("ui_right")):
		hooking = false
		if (rasteira == false) and (lowered == false):
			velocity.x += run_speed
			$AnimatedSprite2.flip_h = false
			$AnimatedSprite2.play("Run")
		if (Input.is_action_pressed("ui_down")):
			rasteira = true
			$AnimatedSprite2.play("Rasteira")
			if (velocity.x < 50):
				rasteira = false
				lowered = true
				$AnimatedSprite2.play("Abaixado")
	elif (Input.is_action_pressed("ui_down")):
		lowered = true
		rasteira = false
		$AnimatedSprite2.play("Abaixado")
	else:
		$AnimatedSprite2.play("Idle")
		rasteira = false
		lowered = false
	velocity.y += delta * gravity

	velocity = move_and_slide(velocity, Vector2(0, -1))
